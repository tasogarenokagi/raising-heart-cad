use <MCAD/utilities.scad>
use <hsmath/lines.scad>

include <vertices.scad>

lerx_root_thickness = 10;

// break out y = mx + b
l1 = mxpb(lerx_vertices[0], lerx_vertices[4]);

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

module lerx_body() {
    color("goldenrod")
    intersection(){
        lerx_length_extrusion();

        linear_extrude(height = lerx_root_thickness, center = true)
            polygon(points = [
                lerx_vertices[0],
                lerx_vertices[1],
                lerx_vertices[2],
                //Skip vertex 3 to clip off the tip
                lerx_vertices[4]
            ]);
    }
}

module lerx_tip() {
    base_length = distance2(lerx_vertices[2], lerx_vertices[4]);
    outer_edge_length = distance2(lerx_vertices[3], lerx_vertices[4]);
    inner_edge_length = distance2(lerx_vertices[2], lerx_vertices[3]);

    //Beat to death with the law of cosines and the right triangle identity.
    extrusion_angle_sin =
        (base_length * base_length + outer_edge_length * outer_edge_length - inner_edge_length * inner_edge_length) /
        (2 * base_length * outer_edge_length);
    extrusion_angle = asin(extrusion_angle_sin);

    color("goldenrod")
    difference() {
        intersection() {
            lerx_length_extrusion();

            translate(lerx_vertices[2])
            rotate([90, 0, extrusion_angle])
            linear_extrude(height = 2 * base_length * extrusion_angle_sin, center = true)
            scale([cos(extrusion_angle), 1, 1])
            projection(cut = true)
            translate([0,0,0.01])
            rotate([-90,0,0])
            translate(-lerx_vertices[2])
                lerx_body();
        }
        
        linear_extrude(height = lerx_root_thickness * 2, center = true)
            polygon(points = [
                    body_vertices[1],
                    body_vertices[2],
                    body_vertices[3],
                    body_vertices[4],
                    [0, -140]
                ]);
    }
}

module lerx() {
    lerx_body();
    lerx_tip();
}

//planform_lerx();
