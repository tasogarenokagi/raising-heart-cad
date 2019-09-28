include <MCAD/units.scad>

use <bezier.scad>

can_diameter = 30;
can_length = 60;

band_width = 2;
band_depth = 1;
band_location = can_length - can_diameter;

endcap_half_angle = 30;
endcap_height = can_diameter / (8 * tan(endcap_half_angle));

can_angles = [-120, 0, 30];
can_location = [-25, 18, 0];

module can_isolated() {
    translate([0, 0, endcap_height]) {
        difference() {
            cylinder(d = can_diameter, h = can_length);

            translate([0, 0, band_location])
            difference() {
                cylinder(d = can_diameter * 1.2, h = band_width, center = true);
                cylinder(d = can_diameter - 2 * band_depth, h = band_width * 3, center = true);
            }
        }

        // Endcap
        translate([0, 0, can_length])
            cylinder(d1 = can_diameter, d2 = can_diameter / 2, h = endcap_height);

        // Root cap
        translate([0, 0, -endcap_height])
            cylinder(d1 = can_diameter / 2, d2 = can_diameter, h = endcap_height);
    }
}

module can_socket_isolated() {
    control_points = [
        [9, 0],
        [16.14545, 0],
        [27.20684, 14.75294],
        [31.81342, 60]
    ];

    rotate_extrude()
        polygon(points = [
            [0, 0],
            each cubic_bezier(control_points[0], control_points[1], control_points[2], control_points[3], 0.05),
            [control_points[3][0], 60],
            [0, 60]
        ]);
}

module can() {
    translate(can_location)
    rotate(can_angles)
    translate([0, 0, (can_length / 4) - epsilon])
        can_isolated();
}

module can_socket() {
    translate(can_location)
    rotate(can_angles)
    translate([0, 0, can_length / 4])
        can_socket_isolated();
}

difference() {
    translate([0, -30, -1])
        cube([30, 60, 30]);
    can_socket_isolated();
}

can_isolated();
