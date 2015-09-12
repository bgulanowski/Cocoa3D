//
//  C3DConstants.h
//  Cocoa3D
//
//  Created by Brent Gulanowski on 2015-09-12.
//  Copyright © 2015 Lichen Labs. All rights reserved.
//

#ifndef C3DConstants_h
#define C3DConstants_h

#define p000 { -1.0f, -1.0f, -1.0f }
#define p00h { -1.0f, -1.0f,  0.0f }
#define p001 { -1.0f, -1.0f,  1.0f }
#define p0h0 { -1.0f,  0.0f, -1.0f }
#define p0hh { -1.0f,  0.0f,  0.0f }
#define p0h1 { -1.0f,  0.0f,  1.0f }
#define p010 { -1.0f,  1.0f, -1.0f }
#define p01h { -1.0f,  1.0f,  0.0f }
#define p011 { -1.0f,  1.0f,  1.0f }

#define ph00 {  0.0f, -1.0f, -1.0f }
#define ph0h {  0.0f, -1.0f,  0.0f }
#define ph01 {  0.0f, -1.0f,  1.0f }
#define phh0 {  0.0f,  0.0f, -1.0f }
#define phhh {  0.0f,  0.0f,  0.0f }
#define phh1 {  0.0f,  0.0f,  1.0f }
#define ph10 {  0.0f,  1.0f, -1.0f }
#define ph1h {  0.0f,  1.0f,  0.0f }
#define ph11 {  0.0f,  1.0f,  1.0f }

#define p100 {  1.0f, -1.0f, -1.0f }
#define p10h {  1.0f, -1.0f,  0.0f }
#define p101 {  1.0f, -1.0f,  1.0f }
#define p1h0 {  1.0f,  0.0f, -1.0f }
#define p1hh {  1.0f,  0.0f,  0.0f }
#define p1h1 {  1.0f,  0.0f,  1.0f }
#define p110 {  1.0f,  1.0f, -1.0f }
#define p11h {  1.0f,  1.0f,  0.0f }
#define p111 {  1.0f,  1.0f,  1.0f }

#define tau (0.70710678118655f) //   τ = 1/√2  = √2/2 =
#define ta2 (0.35355339059328)  // τ/2 = 1/2√2 = √2/4
#define psi (1.1180339887499f)  //   ξ = √5/2 (forgot why this was useful)
#define chi (1.224744871391589) //   χ = √6/3 or √(3/2) = height of

/*
 Tetrahdron vertices aligned with X/Y axes
 */

#define tt01 { -0.5f,  0.0f, -ta2 }
#define tt02 {  0.5f,  0.0f, -ta2 }
#define tt03 {  0.0f,  0.5f,  ta2 }
#define tt04 {  0.0f, -0.5f,  ta2 }

/*
 Tetrahedron vertices with base aligned with X-Y plane
 */

#define ta01 { -0.5f, 0.0f,

/*
 Tetrahedron subscribed in the unit cube
 */

#define phi (1.618033988749895f) // φ: (1+√5)/2
#define ihp (1/phi)


/** The following definitions use phi = φ and ihp = 1/φ **/

/*
 Dodecahedron vertices (from mathworld and wikipedia)
 (  ±1,   ±1,   ±1)
 (   0, ±1/φ,   ±φ)
 (±1/φ,   ±φ,    0)
 (  ±φ,    0, ±1/φ)
 where:
 φ = (1+√5)/2 ≈ 1.6180339875
 */

#define dv01 {   -1,   -1,   -1 }
#define dv02 {   -1,   -1,    1 }
#define dv03 {   -1,    1,   -1 }
#define dv04 {   -1,    1,    1 }
#define dv05 {    1,   -1,   -1 }
#define dv06 {    1,   -1,    1 }
#define dv07 {    1,    1,   -1 }
#define dv08 {    1,    1,    1 }
#define dv09 {    0, -phi, -ihp }
#define dv10 {    0, -phi,  ihp }
#define dv11 {    0,  phi, -ihp }
#define dv12 {    0,  phi,  ihp }
#define dv13 { -phi, -ihp,    0 }
#define dv14 { -phi,  ihp,    0 }
#define dv15 {  phi, -ihp,    0 }
#define dv16 {  phi,  ihp,    0 }
#define dv17 { -ihp,    0, -phi }
#define dv18 { -ihp,    0,  phi }
#define dv19 {  ihp,    0, -phi }
#define dv20 {  ihp,    0,  phi }


/* Icosahedron vertices:
 ( 0, ±1, ±φ)
 (±1, ±φ,  0)
 (±φ,  0, ±1)
 */

#define iv01 {    0,   -1, -phi }
#define iv02 {    0,   -1,  phi }
#define iv03 {    0,    1, -phi }
#define iv04 {    0,    1,  phi }
#define iv05 {   -1, -phi,    0 }
#define iv06 {   -1,  phi,    0 }
#define iv07 {    1, -phi,    0 }
#define iv08 {    1,  phi,    0 }
#define iv09 { -phi,    0,   -1 }
#define iv10 {  phi,    0,   -1 }
#define iv11 { -phi,    0,    1 }
#define iv12 {  phi,    0,    1 }


#endif /* C3DConstants_h */
