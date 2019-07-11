
core_radius = 23.468332;
core_border_radius = 35.65769931;

module head_half() {
    difference() {
        polygon(
            points = [
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
            ]);

            circle(core_border_radius);
    }

    //LERX
    color("goldenrod")
        polygon(
            points = [
                [-93.4998,-35.93688],
                [-52.49256,-53.25047],
                [-46.27154,-128.50401],
                [-49.07658,-132.77946],
                [-54.5424,-128.51475],
                [-68.69342,-46.41036]
            ]);

    //Wing Trailing Edge
    color("goldenrod")
        polygon(
            points = [
                [-196.49172,201.92879],
                [-181.14986,194.44421],
                [-51.74291,22.94061],
                [-60.47434,-0.53228]
            ]);

    //Inner Bevel
    difference() {
        color("yellow") {
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

//Crystal Core
translate([0,0, -0.1]) {
color("crimson")
    circle(core_radius);
}

mirror([1,0,0])
    head_half();

head_half();
