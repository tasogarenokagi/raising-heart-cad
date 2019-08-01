use <lines.scad>

include <vertices.scad>

half_height = 31.2911;
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
}
