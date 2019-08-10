include <MCAD/units.scad>

can_diameter = 30;
can_length = 60;

band_width = 2;
band_depth = 1;
band_location = can_length - can_diameter;

endcap_half_angle = 30;
endcap_height = can_diameter / (8 * tan(endcap_half_angle));

can_angles = [-120, 0, 28];
can_location = [-30, 18, 0];

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
        translate([0, 0, endcap_height]) {
            cylinder(d = can_diameter * 1.4, h = can_length * 1.5);
            translate([0, 0, -endcap_height])
                cylinder(d1 = can_diameter, d2 = can_diameter * 1.4, h = endcap_height);
        }
}

module can() {
    translate(can_location)
    rotate(can_angles)
    translate([0, 0, can_length / 4])
        can_isolated();
}

module can_socket() {
    translate(can_location)
    rotate(can_angles)
    translate([0, 0, can_length / 4])
        can_socket_isolated();
}

difference() {
    cube([50, 50, 20], center = true);
    can_socket_isolated();
}

can_isolated();
