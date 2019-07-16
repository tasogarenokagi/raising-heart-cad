include <MCAD/utilities.scad>

use <lines.scad>

use <lerx.scad>
include <vertices.scad>

half_height = (core_radius*4/3);

module core_hemisphere(r, t) {
    circumscribing_radius = r / cos(t);
    vertical_offset = -r * tan(t);

    color("crimson")
    intersection() {
        translate([0, 0, vertical_offset])
            sphere(circumscribing_radius, $fa=8);
        translate([0, 0, r])
            cube(size = r*2, center = true);
    }
}

body_taper = 0.252592;
module body_cross_section() {
    translate([body_vertices[0][0], body_vertices[8][1],0])
    rotate([90,0,0])
    linear_extrude(height=body_vertices[8][1] - body_vertices[1][1], scale=body_taper)
        polygon(points = [
            [0, -half_height],
            [body_vertices[8][0] - body_vertices[0][0], 0],
            [0, half_height]
        ]);
}

module tip() {
    inner_body_line = mxpb(body_vertices[0], body_vertices[15]);

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
            [bevel_vertices[2][0], 0, body_vertices[1][1] - bevel_vertices[2][1]] ],

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

module half_body() {
    intersection() {
        linear_extrude(height=100, center=true, convexity=4)
            planform_body();
        body_cross_section();
    }
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

            translate([0, body_vertices[0][1] * 0.6 + body_vertices[15][1], 0])
                square([half_height * 2, body_vertices[0][1] * -1.2], center = true);
        }

        linear_extrude(height = half_height * 2, center = true)
            planform_bevel();
    }
}

union() {
    mirror([1,0,0]) {
        planform_full();
    }
    planform_full();
}

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

translate([0, 0, half_height * 0.5])
    core_hemisphere(core_radius, atan(2/3));

mirror([0, 0, 1])
translate([0, 0, half_height * 0.5])
    core_hemisphere(core_radius, atan(2/3));

//$vpr = [253.5, 0, 247.3];
//$vpt = [20.5071, -59.5808, -27.9886];
//$vpd = 755.523;
