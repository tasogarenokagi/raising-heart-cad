include <MCAD/units.scad>

use <lines.scad>

use <body.scad>
include <vertices.scad>

module trailing_edge() {
    
    root_line = mxpb(trailing_edge_vertices[0], trailing_edge_vertices[3]);
    
    root_height = body_heightmap(trailing_edge_vertices[3][0], trailing_edge_vertices[3][1]);
    tip_thickness = body_heightmap(trailing_edge_vertices[0][0], trailing_edge_vertices[0][1]);
    
    color("goldenrod")
    polyhedron( points = [
            [each trailing_edge_vertices[3], root_height],
            [each trailing_edge_vertices[3], -root_height],
            [each trailing_edge_vertices[2], 0],
            
            [each trailing_edge_vertices[0], tip_thickness],
            [each trailing_edge_vertices[0], -tip_thickness],
            [each trailing_edge_vertices[1], 0]
        ],
        faces = [
            [0, 2, 1],
            [0, 1, 4, 3],
            [5, 3, 4],
            [0, 3, 5],
            [0, 5, 2],
            [1, 2, 5],
            [1, 5, 4]
        ],
        convexity = 2
    );
}
