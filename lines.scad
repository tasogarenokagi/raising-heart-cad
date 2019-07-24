
function lineslope(a, b) = (b[1] - a[1]) / (b[0] - a[0]);

/*
    Given a pair of 2D points (a, b) calculate the coefficients of the 
    corresponding line in slope-intercept form.

    Return as a vector [m, b].
 */
function mxpb( a, b ) = [
    lineslope(a, b), 
    b[1] - lineslope(a, b) * b[0]
];

/*
    Given a 2D line in slope-intercept form l = [m_l, b_l]
    and a third point p = [x, y], calculate the slope-intercept
    coefficients of a line perpendicular to the first that
    passes through point p.

    Return as a vector [m, b].
 */
function perpendicular_line( l, p ) = [
    -1 / l[0],
    p[0] - (-1 / l[0]) * p[1]
];

/*
    Given two lines a = [m_a, b_a] and b = [m_b, b_b],
    calculate the point they insersect.

    Return as a vector [x, y];
 */
function lines_intersection(a, b) = [
    (b[1] - a[1]) / (a[0] - b[0]),
    a[0] * ((b[1] - a[1]) / (a[0] - b[0])) + a[1]
];

function distance2(a, b) =
    sqrt( (a[0] - b[0])*(a[0] - b[0]) +
          (a[1] - b[1])*(a[1] - b[1])
    );
