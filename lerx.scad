use <MCAD/utilities.scad>

use <lines.scad>
include <vertices.scad>

lerx_root_thickness = 10;

// break out y = mx + b
l1 = mxpb(lerx_vertices[0], lerx_vertices[len(lerx_vertices) - 1]);

apex = lines_intersection(l1, perpendicular_line(l1, lerx_vertices[1]));
apex_chord_length = length2(apex - lerx_vertices[1]);
edge_length = length2(apex - lerx_vertices[3]);

module lerx_length_extrusion() {
    color("blue")
    translate([lerx_vertices[1][0], lerx_vertices[1][1], -lerx_root_thickness/2])
    rotate([90, 0, atan(-1/l1[0])])
    linear_extrude(height = 2 * edge_length, center = true) {
        polygon(points = [
            [0, 0],
            [0, lerx_root_thickness],
            [-apex_chord_length, lerx_root_thickness/2 + 0.5],
            [-apex_chord_length, lerx_root_thickness/2 - 0.5]
        ]);
    }
}

module lerx() {
    color("goldenrod")
    intersection(){
        lerx_length_extrusion();

        linear_extrude(height = lerx_root_thickness, center = true)
            planform_lerx();
    }
}

planform_full();
lerx();

mirror([1, 0, 0]) {
    planform_full();
    lerx();
}
