use <lines.scad>

include <body.scad>
include <vertices.scad>

function circle_segment_count(r) = $fn > 0 ? ($fn >= 3 ? $fn : 3) : ceil(max(min(360 / $fa, r * 2 * PI / $fs), 5));

function circle_vertices(r) = [ for (i = [0 : circle_segment_count(r) - 1]) [r * cos(i * 360 / circle_segment_count(r)), r * sin(i * 360 / circle_segment_count(r))] ];

border_vertices = circle_vertices(core_border_radius);
core_vertices_2d = circle_vertices(core_radius);
body_line = mxpb(body_vertices[0], body_vertices[13]);

intersects = [
    for (i = [0 : len(border_vertices) - 2])
        let (a = border_vertices[i], b = border_vertices[i + 1])
        lines_intersection(body_line, mxpb(a, b))
];

cull_range = [
    for (i = [0 : len(border_vertices) - 2])
        let (a = border_vertices[i],
            b = border_vertices[i + 1],
            body_intersect = lines_intersection(body_line, mxpb(a, b)))
        if  ((body_intersect[0] <= a[0] && body_intersect[0] >= b[0]) ||
            (body_intersect[0] >= a[0] && body_intersect[0] <= b[0]))
            i
];

culled_start = cull_range[0];
culled_stop = cull_range[1];

culled_vertices = [
    intersects[culled_start],
    for (i = [culled_start + 1 : culled_stop]) border_vertices[i],
    intersects[culled_stop]
];

apex_vertices = [
    for (i = culled_vertices) [i[0], i[1], body_heightmap(i[0], i[1])]
];

hidden_vertices = [
    for (i = culled_vertices) [i[0], i[1], half_height / 2]
];

core_vertices = [
    [each lines_intersection(
        mxpb([0, 0], intersects[culled_start]),
        mxpb(core_vertices_2d[culled_start], core_vertices_2d[culled_start + 1])),
        half_height / 2],

    for (i = [culled_start + 1 : culled_stop])
        [each circle_vertices(core_radius)[i], half_height / 2],

    [each lines_intersection(
        mxpb([0, 0], intersects[culled_stop]),
        mxpb(core_vertices_2d[culled_stop], core_vertices_2d[culled_stop + 1])),
        half_height / 2],
];

slice_count = len(culled_vertices);

module core_bezel() {
    polyhedron(
        points = [
            each apex_vertices,
            each hidden_vertices,
            each core_vertices
        ],

        faces = [
            //slant faces
            for (i = [0 : slice_count - 2]) [i, i + 2 * slice_count, i + 1],
            for (i = [1 : slice_count - 1]) [i - 1 + 2 * slice_count, i + 2 * slice_count, i],

            //back faces
            for (i = [0 : slice_count - 2]) [i, i + 1, i + 1 + slice_count, i + slice_count],

            //bottom face
            [   for (i = [slice_count : 2 * slice_count - 1]) i,
                for (i = [3 * slice_count - 1 : -1 : 2 * slice_count]) i
            ],
            //endcaps
            [0, 0 + slice_count, 0 + 2 * slice_count ],
            [slice_count - 1, 3 * slice_count - 1, 2 * slice_count - 1],
        ],

        convexity = 4
    );
}

module bezel() {
    color("yellow") {
        intersection() {
            rotate([0, 90, 0])
            linear_extrude(height = 40, center = true)
            intersection() {
                projection()
                rotate([0, -90, 0])
                    half_body();

                translate([0, body_vertices[0][1] * 0.6 - core_border_radius])
                    square([half_height * 2, abs(body_vertices[0][1] * 1.2)], center = true);
            }

            linear_extrude(height = half_height * 2, center = true)
                planform_bevel();
        }

        core_bezel();
        mirror([0, 0, 1])
            core_bezel();
    }
}
