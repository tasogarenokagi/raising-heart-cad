core_radius = 23.468332;
core_border_radius = 30;

lerx_vertices = [
    [-68.69342,-46.41036],
    [-52.49256,-53.25047],
    [-50.27154,-128.50401],
    [-58.2647, -132.77946]
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
    lerx_vertices[3],
    lerx_vertices[2],
    lerx_vertices[1],
    //Wing
    [-93.4998,-35.93688],       // 5
    [-150.47711,65.91963],
    [-148.06574,102.74411],
    [-204.01567,205.59936],
    [-196.49172,201.92879],
    trailing_edge_vertices[3],  //10
    trailing_edge_vertices[2],
    //Afterbody
    [-29.46548,52.84187],
    [-16.57433,45.67748]
];

bevel_vertices = [
    body_vertices[13],
    [-3.65164, 38.49567],
    [-3.65164, body_vertices[1][1]],
    body_vertices[0]
];

/* Defines a series of bezier curves.
   Adjacent vertices share their common vertex.
 */
core_body_control_points = [
    [0, -74.53787],

    [-6.33875, -74.53964],
    [-32.29256, -27.42300],

    [-35.57901, 0.92603],

    [-37.05366, 13.64633],
    [-33.68487, 21.96261],

    [-23.71482, 29.99877],

    [-16.60109, 35.73268],
    [-10.09255, 38.47175],

    [0, 38.47175]
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

module planform_bevel() {
    color("yellow")
    difference() {
        union() {
            polygon(points = bevel_vertices);

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

module planform_full() {
    planform_body();
    planform_lerx();
    planform_trailing_edge();
    planform_bevel();
}
