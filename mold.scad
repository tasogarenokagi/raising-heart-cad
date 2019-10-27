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

split_point_inner = apex_vertices[0];
split_face_line = mxpb(body_vertices[11], body_vertices[12]);
split_point = [(split_point_inner[1] - split_face_line[1]) / split_face_line[0], split_point_inner[1]];

back_envelope_half = [
    [body_vertices[12][0], body_vertices[12][1] + epsilon],
    [split_point[0] - epsilon, split_point[1]],
    [apex_vertices[0][0], apex_vertices[0][1]],
    [tail_corner_core_vertices[0][0], tail_corner_core_vertices[0][1]],
];

back_envelope_vertices = [
    for (i = [0 : len(back_envelope_half) - 1]) back_envelope_half[i],
    for (i = [len(back_envelope_half) - 1 : -1 : 0]) [-back_envelope_half[i].x, back_envelope_half[i].y],
];

back_tail_envelope_vertices = [
    for (i = [0 : 1]) back_envelope_vertices[i],
    for (i = [6 : 7]) back_envelope_vertices[i],
];

back_cap_envelope_vertices = [
    for (i = [2 : 5]) back_envelope_vertices[i],
];

module back_clipping_solid(mode) {
    linear_extrude(height = half_height * 2, convexity = 4, center = true) {
        difference() {
            polygon(points = back_envelope_vertices, convexity = 4);

            if (mode == "cylinder") {
                circle(r = core_radius);
            }
        }
    }
}

module back_tail_clipping_solid(mode) {
    linear_extrude(height = half_height * 2, convexity = 4, center = true)
        polygon(points = back_tail_envelope_vertices, convexity = 4);
}

module back_cap_clipping_solid(mode) {
    linear_extrude(height = half_height * 2, convexity = 4, center = true) {
        difference() {
            polygon(points = back_cap_envelope_vertices, convexity = 4);

            if (mode == "cylinder") {
                circle(r = core_radius);
            }
        }
    }
}
