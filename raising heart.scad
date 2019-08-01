include <MCAD/units.scad>

use <lines.scad>
use <bezier.scad>

use <lerx.scad>
include <body.scad>
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

module tip() {
    inner_body_line = mxpb(body_vertices[0], body_vertices[13]);

    // outside corner is at body_vertices[1]
    inside_body_corner = [ (body_vertices[1][1] - inner_body_line[1]) / inner_body_line[0], body_vertices[1][1] ];

    cross_section_line = mxpb(
        [body_vertices[0][0], half_height * body_taper],
        [(body_vertices[8][0] - body_vertices[0][0]) * body_taper + body_vertices[0][0], 0]);

    inner_height = cross_section_line[0] * inside_body_corner[0] + cross_section_line[1];
    outer_height = cross_section_line[0] * body_vertices[1][0] + cross_section_line[1];

    translate([0, body_vertices[1][1], 0])
    rotate([90,0,0])
        polyhedron( points = [
            [inside_body_corner[0], inner_height, 0],
            [body_vertices[1][0], outer_height, 0],
            [body_vertices[1][0], -outer_height, 0],
            [inside_body_corner[0], -inner_height, 0],
            [bevel_vertices[2][0], -inner_height, 0],
            [bevel_vertices[2][0], inner_height, 0],
            [body_vertices[0][0], 0, body_vertices[1][1] - body_vertices[0][1]] ],

            faces = [
                [0, 6, 1],
                [1, 6, 2],
                [2, 6, 3],
                [3, 6, 4],
                [4, 6, 5],
                [5, 6, 0],
                [0, 1, 2, 3, 4, 5]
            ],
            convexity = 2
        );
}

module bezel_section() {
    color("yellow")
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
}

module core_housing() {
    cylinder(r=core_border_radius, h=half_height, center = true);
    difference() {
        scale([1, 1, 0.58])
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
            cylinder(r=core_border_radius, half_height, center = true);
        translate([0, 0, -half_height])
            cylinder(r=core_border_radius, half_height, center = true);
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
    tip();
    bezel_section();
}
half_body();
lerx();
tip();
bezel_section();

core_half(core_radius, atan(2/3));
mirror([0, 0, 1]) {
    core_half(core_radius, atan(2/3));
}

core_housing();

rotate([-90, 0, 0])
    staff();

//polygon(points = [ for(i = [0 : 1 : len(body_vertices) - 3]) body_vertices[i]]);
//$vpr = [230.40, 0.00, 246.60];
//$vpt = [20.5071, -59.5808, -27.9886];
//$vpd = 755.523;
