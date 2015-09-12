//
//  C3DObject+C3DPolyhedra.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2015-09-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#import <Cocoa3D/Cocoa3D.h>

// These are created without a program set

@interface C3DObject (C3DPolyhedra)

// polyhedra composed of unit vectors
+ (instancetype)unitTetrahedron;
+ (instancetype)unitRectangularPrism;
+ (instancetype)unitCube;

// polyhedra centered on the origin
+ (instancetype)tetrahedron;
+ (instancetype)rectangularPrism;
+ (instancetype)octahedron;

@end

@interface C3DVertexBuffer (C3DPolyhedra)
// singleton instances
+ (instancetype)unitPositions;
+ (instancetype)unitColours;
@end
