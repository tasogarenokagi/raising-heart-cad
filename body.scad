use <lines.scad>

include <vertices.scad>

body_taper = 0.252592;

module body_cross_section() {
    translate([body_vertices[0][0], body_vertices[8][1], 0])
    rotate([90,0,0])
    linear_extrude(height=body_vertices[8][1] - body_vertices[1][1], scale=body_taper) {
        polygon(points = [
            [0, -half_height],
            [body_vertices[8][0] - body_vertices[0][0], 0],
            [0, half_height]
        ]);
    }
}

function body_heightmap(x, y) =
    (-half_height / (body_vertices[8][0] - body_vertices[0][0])) * (x - body_vertices[0][0])
    + (half_height * (1 - body_taper) / (body_vertices[8][1] - body_vertices[1][1])) * (y - body_vertices[8][1])
    + half_height;

//module body_cross_section() {
//    translate([body_vertices[0][0], body_vertices[8][1],0])
//    rotate([90,0,0])
//    linear_extrude(height=body_vertices[8][1] - body_vertices[1][1], scale=body_taper)
//    scale([(body_vertices[8][0] - body_vertices[0][0]) / half_height, 1, 1])
//    intersection() {
//        translate([0, -half_height])
//            square(size = [half_height, 2 * half_height]);
//        circle(r = half_height);
//    }
//}

module half_body() {
    intersection() {
        linear_extrude(height=100, center=true, convexity=4)
            planform_body();
         body_cross_section();
    }

    inner_body_line = mxpb(body_vertices[0], body_vertices[13]);

    inside_body_corner = [ (body_vertices[1][1] - inner_body_line[1]) / inner_body_line[0], body_vertices[1][1] ];
    outside_corner = body_vertices[1];
    apex = body_vertices[0];

    inner_height = body_heightmap(inside_body_corner[0], inside_body_corner[1]);
    outer_height = body_heightmap(outside_corner[0], outside_corner[1]);

    translate([0, outside_corner[1], 0])
    rotate([90,0,0])
        polyhedron( points = [
                [inside_body_corner[0], inner_height, 0],
                [outside_corner[0], outer_height, 0],
                [outside_corner[0], -outer_height, 0],
                [inside_body_corner[0], -inner_height, 0],
                [apex[0], 0, inside_body_corner[1] - apex[1]],
                [body_vertices[0][0], -inner_height, 0],
                [body_vertices[0][0], inner_height, 0]
            ],
            faces = [
                [1, 0, 4],
                [2, 1, 4],
                [3, 2, 4],
                [0, 1, 2, 3, 5, 6],
                [3, 4, 5],
                [0, 6, 4],
                [6, 5, 4]
            ],
            convexity = 2
        );
}
