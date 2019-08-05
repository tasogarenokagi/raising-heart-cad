include <MCAD/units.scad>

use <lines.scad>
use <bezier.scad>

use <bezel.scad>
use <body.scad>
use <lerx.scad>
use <trailing edge.scad>

include <vertices.scad>

$fa=6;

module core_half(r, t) {
    circumscribing_radius = r / cos(t);
    vertical_offset = -r * tan(t);

    color("crimson")
    translate([0, 0, -vertical_offset])
    intersection() {
        translate([0, 0, vertical_offset])
            sphere(circumscribing_radius);
        translate([0, 0, r])
            cube(size = r*2, center = true);
    }
}

module core_housing() {
    cylinder(r=core_border_radius, h=half_height, center = true);
    difference() {
        scale([1, 1, 0.6])
        rotate([-90, 0, 0])
        rotate_extrude(angle = 360, convexity = 10) {

            polygon(cubic_bezier(core_body_control_points[0], core_body_control_points[1], core_body_control_points[2], core_body_control_points[3], 0.01));
            polygon(cubic_bezier(core_body_control_points[3], core_body_control_points[4], core_body_control_points[5], core_body_control_points[6], 0.1));
            polygon(cubic_bezier(core_body_control_points[6], core_body_control_points[7], core_body_control_points[8], core_body_control_points[9], 0.1));

            polygon(points = [
                core_body_control_points[0],
                core_body_control_points[3],
                core_body_control_points[6],
                core_body_control_points[9]
            ]);
        }

        translate([0, 0, half_height])
            cylinder(r=100, half_height, center = true);
        translate([0, 0, -half_height])
            cylinder(r=100, half_height, center = true);
    }
}

module can() {
    can_diameter = 30;
    can_length = 2 * can_diameter;
    frustrum_half_angle = 30;

    band_width = 2;
    band_depth = 1;

    translate([-32, 20, 0])
    rotate([-110, 0, 25])
    translate([0, 0, can_length / 4]) {
        translate([0, 0, -can_length / 4])
            cylinder(d = can_diameter, h = (can_length * 3 / 4)  - band_width / 2);
        translate([0, 0, (can_length + band_width) / 2])
            cylinder(d = can_diameter, h = (can_length - band_width) / 2);
        cylinder(d = can_diameter - 2 * band_depth, h = can_length);
        translate([0, 0, can_length])
            cylinder(d1 = can_diameter, d2 = can_diameter / 2, h = can_diameter / (8 * tan(frustrum_half_angle)));
    }
}

module staff() {
    //Check references!  The part near the head is thinner than the grip!
    overall_length = 5 * 12 * inch;
    neck_length = 8 * inch;
    remaining_length = overall_length - neck_length;

    neck_diameter = 1 * inch;
    grip_diameter = 4/3 * inch;

    color("hotpink")
    cylinder(h = 12 * inch, d = neck_diameter);

    color("white")
    translate([0, 0, neck_length])
    linear_extrude(height = remaining_length)
    difference() {
        circle(d = grip_diameter);
        circle(d = neck_diameter);
    }

    cylinder(d = half_height, h = body_vertices[12][1]);

    translate([0, 0, body_vertices[12][1] + 2])
        cylinder(d1 = half_height, d2 = neck_diameter, h = 30);
}

//union() {
//    mirror([1,0,0]) {
//        planform_full();
//    }
//    planform_full();
//}

// Completed model below
mirror([1,0,0]) {
    half_body();
    lerx();
    bezel();
    trailing_edge();
    can();
}
half_body();
lerx();
bezel();
trailing_edge();
can();
core_housing();


core_half(core_radius, atan(2/3));
mirror([0, 0, 1]) {
    core_half(core_radius, atan(2/3));
}

rotate([-90, 0, 0])
    staff();

//$vpr = [230.40, 0.00, 246.60];
//$vpt = [20.5071, -59.5808, -27.9886];
//$vpd = 755.523;
