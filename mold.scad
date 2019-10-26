include <MCAD/units.scad>
include <MCAD/utilities.scad>

use <lines.scad>

include <bezel.scad>
include <vertices.scad>

module mold() {
    render(convexity = 12)
    difference() {
        translate([0, -100, -25])
            cube([500, 650, 50], center = true);

        children();
    }
}

module mold_back_clipping_brush(mode) {
    linear_extrude(height = half_height * 2, convexity = 4, center = true) {
        difference() {
            mold_back_polygon();
            
            if (mode == "cylinder") {
                circle(r = core_radius);
            }
        }
    }
}

module mold_back_polygon() {
    split_point_inner = apex_vertices[0];
    split_face_line = mxpb(body_vertices[11], body_vertices[12]);
    split_point = [(split_point_inner[1] - split_face_line[1]) / split_face_line[0], split_point_inner[1]];

    constraints = [
        [body_vertices[12][0], body_vertices[12][1] + epsilon],
        [split_point[0] - epsilon, split_point[1]],
        [apex_vertices[0][0], apex_vertices[0][1]],
        [tail_corner_core_vertices[0][0], tail_corner_core_vertices[0][1]],
        [-tail_corner_core_vertices[0][0], tail_corner_core_vertices[0][1]],
        [-apex_vertices[0][0], apex_vertices[0][1]],
        [-split_point[0] + epsilon, split_point[1]],
        [-body_vertices[12][0], body_vertices[12][1] + epsilon],
    ];

    polygon(points = constraints, convexity = 4);
}
