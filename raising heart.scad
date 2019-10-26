include <MCAD/units.scad>

use <lines.scad>
use <bezier.scad>

use <bezel.scad>
use <body.scad>
use <can.scad>
use <core.scad>
use <lerx.scad>
use <mold.scad>
use <trailing edge.scad>

include <vertices.scad>

$fn = 60;

ASSEMBLE_HEAD = "ASSEMBLE_HEAD";
ASSEMBLE_FULL = "ASSEMBLE_FULL";
ASSEMBLE_MOLD = "ASSEMBLE_MOLD";
ASSEMBLE_MOLD_POSITIVE = "ASSEMBLE_MOLD_POSITIVE";
ASSEMBLE_REAR = "ASSEMBLE_REAR";
ASSEMBLE_HACKJOB = "ASSEMBLE_HACKJOB";

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

module assemble_half_head(assembly_mode) {
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
    if (assembly_mode == ASSEMBLE_HEAD) {
        can();
    }
}

module full_head(assembly_mode) {
    mirror([1,0,0]) {
        assemble_half_head(assembly_mode);
    }

    assemble_half_head(assembly_mode);

    if (assembly_mode == ASSEMBLE_MOLD) {
        core_housing();
    } else {
        core_assembly();
    }
}

module assemble_parts(assembly_mode) {
    if (assembly_mode == ASSEMBLE_HEAD) {
        full_head(ASSEMBLE_HEAD);
    } else if (assembly_mode == ASSEMBLE_FULL) {
        full_head(ASSEMBLE_HEAD);
        staff();
    } else if (assembly_mode == ASSEMBLE_MOLD) {
        mold()
        difference(){
            full_head(ASSEMBLE_MOLD);
            mold_back_clipping_brush("cylinder");
        }
    } else if (assembly_mode == ASSEMBLE_MOLD_POSITIVE) {
        difference(){
            full_head(ASSEMBLE_MOLD);
            mold_back_clipping_brush("cylinder");
        }
    } else if (assembly_mode == ASSEMBLE_REAR) {
        intersection() {
            full_head(ASSEMBLE_MOLD);
            mold_back_clipping_brush("cylinder");
        }
    } else if (assembly_mode == ASSEMBLE_HACKJOB) {
    }
}

/*
    ASSEMBLE_HEAD - Complete head, with core spheres and cans
    ASSEMBLE_FULL - The complete head plus the staff and staff fittings
    ASSEMBLE_MOLD - Negative mold of the head, with geometry changes to make it suitable for thermoforming
    ASSEMBLE_MOLD_POSITIVE - Positive of the mold cavity
    ASSEMBLE_REAR - Negative mold of the rear part of the head, including the can sockets
    ASSEMBLE_HACKJOB - Sandbox for whatever I'm working on currently
 */

assemble_parts(ASSEMBLE_FULL);

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
