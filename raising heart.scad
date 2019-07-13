include <MCAD/utilities.scad>

core_radius = 23.468332;
core_border_radius = 35.65769931;

lerx_vertices = [
    [-68.69342,-46.41036],
    [-52.49256,-53.25047],
    [-46.27154,-128.50401],
    [-49.07658,-132.77946],
    [-54.5424,-128.50401]
];

trailing_edge_vertices = [
    [-196.49172,201.92879],
    [-181.14986,194.44421],
    [-51.74291,22.94061],
    [-60.47434,-0.53228]
];

body_vertices = [
    //Spear
    [-8.64594,-383.27424],
    [-33.36415,-339.00235],
    [-49.07658,-132.77946],
    [-46.27154,-128.50401],
    [-52.49256,-53.25047],
    //Wing
    [-93.4998,-35.93688],
    [-150.47711,65.91963],
    [-148.06574,102.74411],
    [-204.01567,205.59936],
    [-196.49172,201.92879],
    [-60.47434,-0.53228],
    [-51.74291,22.94061],
    //Afterbody
    [-29.46548,52.84187],
    [-16.57433,45.67748],
    //Core Cutout
    [-16.60024,31.55794],
    [-18.58465,-30.43157]
];

module planform_body() {
    difference() {
        polygon(points = body_vertices);

        circle(core_border_radius);
    }
}

module planform_lerx() {
    color("goldenrod")
        polygon(points = lerx_vertices);
}

module planform_trailing_edge() {
    color("goldenrod")
        polygon(points = trailing_edge_vertices);
}

module head_lerx() {
    lerx_root_thickness = 10;
    
    // break out y = mx + b
    m1 = (lerx_vertices[4][1] - lerx_vertices[0][1]) / (lerx_vertices[4][0] - lerx_vertices[0][0]);
    b1 = lerx_vertices[0][1] - m1 * lerx_vertices[0][0];
    m2 = -1 / m1;
    b2 = lerx_vertices[1][1] - m2 * lerx_vertices[1][0];
    
    apex = [(b2 - b1) / (m1 - m2), m1 * ((b2 - b1) / (m1 - m2)) + b1];
    apex_chord_length = length2(apex - lerx_vertices[1]);
    edge_length = length2(apex - lerx_vertices[4]);

    color("goldenrod")
    intersection(){
        color("blue")
        translate([lerx_vertices[1][0], lerx_vertices[1][1], -lerx_root_thickness/2])
        rotate([90, 0, atan(-1/m1)])
        linear_extrude(height = 2 * edge_length, center = true) {
            polygon(points = [
                [0, 0],
                [0, lerx_root_thickness],
                [-apex_chord_length, lerx_root_thickness/2]
            ]);
        }

        linear_extrude(height = lerx_root_thickness, center = true)
            planform_lerx();
    }
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

mirror([1,0,0]) {
    planform_body();
    planform_lerx();
    planform_trailing_edge();
    inner_bevel();
}

planform_body();
planform_lerx();
planform_trailing_edge();
inner_bevel();

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

// Completed model below
head_lerx();
intersection() {
    linear_extrude(height=100, center=true, convexity=4)
        planform_body();
    thickness();
}

mirror([1,0,0]) {
    head_lerx();
    
    intersection() {
        linear_extrude(height=100, center=true, convexity=4)
            planform_body();
        thickness();
    }
}

translate([0, 0, half_height * 0.5])
    core_hemisphere();

mirror([0, 0, 1])
translate([0, 0, half_height * 0.5])
    core_hemisphere();
