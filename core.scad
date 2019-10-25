include <MCAD/units.scad>

use <bezier.scad>

include <vertices.scad>

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

module core_sphere() {
    core_half(core_radius, atan(2/3));
}

module core_spheres() {
    mirror([0, 0, 1])
    translate([0, 0, -epsilon])
        core_sphere();

    translate([0, 0, -epsilon])
        core_sphere();
}

module core_housing() {
    difference() {
        scale([1, 1, 0.605])
        rotate([-90, 0, 0])
        rotate_extrude(angle = 360, convexity = 10) {

            polygon(cubic_bezier(core_body_control_points[0], core_body_control_points[1], core_body_control_points[2], core_body_control_points[3], 0.01));

            polygon(points = [
                core_body_control_points[0],
                core_body_control_points[3],
                [-20, 20],
                [0, 20]
            ]);
        }

        translate([0, 0, half_height])
            cylinder(r=100, half_height, center = true);
        translate([0, 0, -half_height])
            cylinder(r=100, half_height, center = true);
    }

    cylinder(r=core_border_radius, h=half_height, center = true);
}

module core_assembly() {
    core_housing();
    core_spheres();
}

core_assembly();
