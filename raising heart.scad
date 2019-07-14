include <MCAD/utilities.scad>

use <lerx.scad>
include <vertices.scad>

module planform_body() {
    difference() {
        polygon(points = body_vertices);

        circle(core_border_radius);
    }
}

//module planform_lerx() {
//    color("goldenrod")
//        polygon(points = lerx_vertices);
//}

module planform_trailing_edge() {
    color("goldenrod")
        polygon(points = trailing_edge_vertices);
}

module inner_bevel() {
    color("yellow")
    //linear_extrude(height=half_height, center=true, convexity=4)
    difference() {
        union() {
            polygon(
                points = [
                [-16.57433,45.67748],
                [-3.65164,38.49567],
                [-3.65164,-369.76703],
                [-8.64594,-383.27424],
                [-18.58465,-30.43157]
                ]);

            difference() {
                    circle(core_border_radius);

                polygon(
                    points = [
                        [-16.57433,45.67748],
                        [-3.65164,-369.76703],
                        [95,65]
                    ]);
            }
        }

        circle(core_radius);
    }
}

half_height = (core_radius*4/3);

module core_hemisphere() {
    color("crimson")
    intersection() {
        sphere(core_radius);
        translate([0, 0, core_radius])
            cube(size = core_radius*2, center = true);
    }
}

//mirror([1,0,0]) {
//    planform_full();
//}
//planform_full();

module thickness() {
    translate([0,205.59936,0])
    rotate([90,0,0])
    linear_extrude(height=339.00235+205.59936, scale=0.252592)
        polygon(points = [
            [-8.64594, -half_height],
            [-204.01567, 0],
            [-8.64594, half_height],
        ]);
}


/*mirror([1,0,0])
    thickness();
thickness();*/

module half_body() {
    intersection() {
        linear_extrude(height=100, center=true, convexity=4)
            planform_body();
        thickness();
    }

    lerx();
}
// Completed model below
mirror([1,0,0]) {
    half_body();
}
half_body();

translate([0, 0, half_height * 0.5])
    core_hemisphere();

mirror([0, 0, 1])
translate([0, 0, half_height * 0.5])
    core_hemisphere();
