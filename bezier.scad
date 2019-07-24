
function quadratic_bezier(p0, p1, p2, stepsize) =
    [for (t = [0 : stepsize : 1 - stepsize * 0.5]) pow(1 - t, 2) * p0 + 2 * (1 - t) * t * p1 + t * t * p2, p2];

function cubic_bezier(p0, p1, p2, p3, stepsize) =
    [for (t = [0 : stepsize : 1 - stepsize * 0.5]) pow(1 - t, 3) * p0 + 3 * pow(1 - t, 2) * t * p1 + 3 * (1 - t) * t * t * p2 + pow(t, 3) * p3, p3];
