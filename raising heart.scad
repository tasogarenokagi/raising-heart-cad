include <MCAD/units.scad>

use <lines.scad>
use <bezier.scad>

use <bezel.scad>
use <body.scad>
use <can.scad>
use <core.scad>
use <lerx.scad>
use <trailing edge.scad>

include <vertices.scad>

$fa=6;

module mold_shims() {
    linear_extrude(height = half_height, center = true)
        polygon([
            [bevel_vertices[1][0], 0],
            bevel_vertices[1],
            bevel_vertices[0],
            [bevel_vertices[0][0], 0]
        ]);
    mirror([1, 0, 0])
        linear_extrude(height = half_height, center = true)
            polygon([
                [bevel_vertices[1][0], 0],
                bevel_vertices[1],
                bevel_vertices[0],
                [bevel_vertices[0][0], 0]
            ]);
    translate([0, abs(bevel_vertices[1][1]) / 2, 0])
        cube([abs(body_vertices[13][0]) * 2, abs(bevel_vertices[1][1]), half_height - 2], center = true);
}

module staff() {
    //Check references!  The part near the head is thinner than the grip!
    overall_length = 5 * 12 * inch;
    neck_length = 8 * inch;
    remaining_length = overall_length - neck_length;

    neck_diameter = 1 * inch;
    grip_diameter = 4/3 * inch;

    rotate([-90, 0, 0]) {
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
}

module full_head(mold = false) {
    mirror([1,0,0]) {
        difference() {
            half_body();

            can_socket();
            spear_clipping_brushes();
            mirror([0, 0, 1])
                spear_clipping_brushes();
        }
        lerx();
        bezel();
        trailing_edge();
        if (mold == false) {
            can();
        }
    }

    difference() {
        half_body();

        can_socket();
        spear_clipping_brushes();
        mirror([0, 0, 1])
            spear_clipping_brushes();
    }
    lerx();
    bezel();
    trailing_edge();
    if (mold == false) {
        can();
    }

    if (mold == true) {
        mold_shims();
        core_housing();
    } else {
        core_assembly();
    }
}

module mold() {
    difference() {
        translate([0, -100, -25])
            cube([500, 650, 50], center = true);

        translate([0, 0, -1]) {
            linear_extrude(height = 1, convexity = 5)
            projection()
                full_head(true);

            full_head(true);
        }
    }
}

full_head();
//staff();

//mold();

//ffmpeg -r 30 -i frame%05d.png -c:v libvpx -crf 4 -b:v 1M -an -r 30 spin.webm
//$vpt = [0, -56.9, -16.6];
//$vpr = [64, 0, (330 + 360 * $t) % 360];
//$vpd = 1024;

//$vpr = [50.4, 0.00, 293.4];
//$vpt = [45.56, -34.41, 10.65];
//$vpd = 755.523;

// Duplicate pose in scan 0037
//$vpr = [181, 330, 219];
//$vpt = [26.34, 19.43, -4.27];
//$vpd = 1659.67;
