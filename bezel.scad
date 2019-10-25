use <MCAD/utilities.scad>

use <lines.scad>

use <body.scad>
include <vertices.scad>

function circle_segment_count(r) = $fn > 0 ? ($fn >= 3 ? $fn : 3) : ceil(max(min(360 / $fa, r * 2 * PI / $fs), 5));

function circle_vertices(r) = [ for (i = [0 : circle_segment_count(r) - 1]) [r * cos(i * 360 / circle_segment_count(r)), r * sin(i * 360 / circle_segment_count(r))] ];

border_vertices = circle_vertices(core_border_radius);
core_vertices_2d = circle_vertices(core_radius);
body_line = mxpb(body_vertices[0], body_vertices[13]);
bezel_coord = bevel_vertices[1][0]; // vertical line, can't use mxpb()

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
        [each core_vertices_2d[i], half_height / 2],

    [each lines_intersection(
        mxpb([0, 0], intersects[culled_stop]),
        mxpb(core_vertices_2d[culled_stop], core_vertices_2d[culled_stop + 1])),
        half_height / 2],
];

slice_count = len(culled_vertices);

tail_corner_culling = [
    for (i = [0 : len(core_vertices_2d) - 2])
        let (a = core_vertices_2d[i], b = core_vertices_2d[i + 1])
        if (a[0] >= bezel_coord && b[0] <= bezel_coord)
            i
][0];

tail_corner_core_segment = mxpb(core_vertices_2d[tail_corner_culling], core_vertices_2d[tail_corner_culling + 1]);
tail_corner_core_vertices = [
    [bezel_coord, bezel_coord * tail_corner_core_segment[0] + tail_corner_core_segment[1], half_height / 2],
    for(i = [tail_corner_culling + 1 : culled_start])
        [each core_vertices_2d[i], half_height / 2],
    core_vertices[0]
];

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

module tail_bezel() {
    corner_apex = apex_vertices[0];
    corner_base = hidden_vertices[0];

    vertex_count = len(tail_corner_core_vertices);

    polyhedron(points = [
            each tail_corner_core_vertices,
            corner_apex,
            corner_base
        ],
        faces = [
            [vertex_count, vertex_count - 1, vertex_count + 1],
            [vertex_count + 1, for(i = [vertex_count - 1 : -1 : 0]) i],
            [0, vertex_count, vertex_count + 1],
            for(i = [0 : vertex_count - 2]) [i, i + 1, vertex_count]
        ],
        convexity = 4
    );

    polyhedron(points = [
            corner_apex,
            corner_base,
            [each bevel_vertices[0], body_heightmap(bevel_vertices[0][0], bevel_vertices[0][1])],
            [each bevel_vertices[0], half_height / 2],
            [each bevel_vertices[1], half_height / 2],
            tail_corner_core_vertices[0]
        ],
        faces = [
            [0, 5, 1],
            [0, 1, 3, 2],
            [4, 3, 1, 5],
            [4, 2, 3],
            [0, 2, 5],
            [2, 4, 5],
        ],
        convexity = 4
    );
}

module spear_corner() {
    corner_apex = apex_vertices[slice_count - 1];
    corner_base = hidden_vertices[slice_count - 1];

    spear_culling = [
        for (i = [0 : len(core_vertices_2d) - 2])
            let (a = core_vertices_2d[i], b = core_vertices_2d[i + 1])
            if (a[0] <= bezel_coord && b[0] >= bezel_coord)
                i
    ][0];

    core_segment = mxpb(core_vertices_2d[spear_culling], core_vertices_2d[spear_culling + 1]);
    corner_vertices = [
        core_vertices[slice_count - 1],
        for(i = [culled_stop + 1: spear_culling])
            [each core_vertices_2d[i], half_height / 2],
        [bezel_coord, bezel_coord * core_segment[0] + core_segment[1], half_height / 2]
    ];

    vertex_count = len(corner_vertices);

    polyhedron(points = [
            each corner_vertices,
            corner_apex,
            corner_base,
            [bezel_coord, corner_apex[1], half_height / 2]
        ],
        faces = [
            [vertex_count, vertex_count + 1, 0],
            [vertex_count + 2, vertex_count + 1, vertex_count],
            [vertex_count + 1, vertex_count + 2, for(i = [vertex_count - 1 : -1 : 0]) i],
            [vertex_count, vertex_count - 1, vertex_count + 2],
            for(i = [0 : vertex_count - 2]) [i, i + 1, vertex_count]
        ],
        convexity = 4
    );
}

module spear_clipping_brushes() {
    clipping_width = 3 * distance(apex_vertices[slice_count - 1], [bezel_coord, apex_vertices[slice_count - 1][1], half_height / 2]);

    inner_body_line = mxpb(body_vertices[0], body_vertices[13]);
    inside_vertex = [ (body_vertices[1][1] - inner_body_line[1]) / inner_body_line[0], body_vertices[1][1] ];

    inside_body_corner = [each inside_vertex, body_heightmap(inside_vertex[0], inside_vertex[1])];

    body_slant_angles = angleBetweenTwoPoints(
        apex_vertices[slice_count - 1],
        inside_body_corner);
    body_slant_length = distance(
        apex_vertices[slice_count - 1],
        inside_body_corner);
    tip_slant_angles = angleBetweenTwoPoints(
        inside_body_corner,
        [each body_vertices[0], 0]);
    tip_slant_length = distance(
        inside_body_corner,
        [each body_vertices[0], 0]);

    clipping_angle = angleBetweenTwoPoints(
        [bezel_coord, apex_vertices[slice_count - 1][1], half_height / 2],
        apex_vertices[slice_count - 1])[1];

    translate(apex_vertices[slice_count - 1])
    rotate([clipping_angle, body_slant_angles[1], body_slant_angles[2]])
    translate([body_slant_length / 2, 0, clipping_width / 2])
        cube([body_slant_length, clipping_width, clipping_width], center = true);

    translate(inside_body_corner)
    rotate([clipping_angle, tip_slant_angles[1], tip_slant_angles[2]])
    translate([0, 0, clipping_width / 2])
        cube([body_slant_length, clipping_width, clipping_width], center = true);
}

module spear_bezel() {
    color("yellow")
    difference() {
        intersection() {
            rotate([0, 90, 0])
            linear_extrude(height = 40, center = true)
            intersection() {
                projection()
                rotate([0, -90, 0])
                    half_body();

                translate([0, body_vertices[0][1] * 0.6 + apex_vertices[slice_count - 1][1] ])
                    square([half_height * 2, abs(body_vertices[0][1] * 1.2)], center = true);
            }

            linear_extrude(height = half_height * 2, center = true)
                planform_bevel();
        }

        spear_clipping_brushes();
        mirror([0, 0, 1])
            spear_clipping_brushes();
    }
}

module bezel() {
    spear_corner();
    spear_bezel();
    core_bezel();
    tail_bezel();
    mirror([0, 0, 1]) {
        spear_corner();
        core_bezel();
        tail_bezel();
    }
}
