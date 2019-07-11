
core_center = [206.50742, 383.56781];
core_radius = 23.468332;
core_border_radius = 35.65769931;

module head_half() {
    difference() {
        polygon(
            points = [
                //Spear
                [200.28869,0.24650519],
                [175.29063,44.360985],
                [158.27263,250.48024],
                [161.05054,254.77337],
                [154.35311,329.98601],
                //Wing
                [113.23706,347.03958],
                [55.615897,448.53324],
                [57.794039,485.37225],
                [1.1939122,587.87115],
                [8.7409485,584.24829],
                [146.03766,382.65259],
                [154.62028,406.1803],
                //Afterbody
                [176.70792,436.22203],
                [189.64418,429.13942],
                //Core Cutout
                [189.70768,415.0200],
                [188.11585,353.01917]
            ]);
        translate(core_center)
            circle(core_border_radius);
    }

    //LERX
    color("goldenrod")
        polygon(
            points = [
                [113.23706,347.03958],
                [154.35311,329.98601],
                [161.05054,254.77337],
                [158.27263,250.48024],
                [152.77992,254.71025],
                [138.10926,336.72339]
            ]);

    //Wing Trailing Edge
    color("goldenrod")
        polygon(
            points = [
                [8.7409485,584.24829],
                [24.1299,576.86101],
                [154.62028,406.1803],
                [146.03766,382.65259]
            ]);

    //Inner Bevel
    difference() {
        color("yellow") {
            polygon(
                points = [
                    [189.64418,429.13942],
                    [202.61208,422.03958],
                    [205.19735,13.785075],
                    [200.28869,0.24650519],
                    [188.11585,353.01917]
                ]);

            difference() {
                translate(core_center)
                    circle(core_border_radius);

                polygon(
                    points = [
                        [189.64418,429.13942],
                        [205.19735,13.785075],
                        [300,450]
                    ]);
            }
        }
        
        translate(core_center)
            circle(core_radius);
    }
}

//Crystal Core
translate([0,0, -0.1]) {
//translate([core_center[0], core_center[1], -4]) {
    color("crimson") {
        circle(core_radius);
    }
}

dx = 205.19735 - 202.61208;
dy = 422.03958 - 13.785075;
//-0.362820442
deskew_rotation = [0,0,-asin(dx/sqrt(pow(dx,2) + pow(dy,2)))];

//translate(core_center)
mirror([1,0,0])
rotate(deskew_rotation)
translate(-core_center)
head_half();

//translate(core_center)
rotate(deskew_rotation)
translate(-core_center)
head_half();
