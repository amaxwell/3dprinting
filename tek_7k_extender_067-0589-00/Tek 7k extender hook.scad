//
// Licensed under MIT license, due to inclusion of polyedge code
//
// All other code is Copyright (c) 2025 Adam R. Maxwell
// posted to https://groups.io/g/TekScopes/message/210788
// 

function mm(inches) = inches * 25.4;

$fn=200;

module rounded_square( width, radius_corner ) {
	translate( [ radius_corner, radius_corner, 0 ] )
		minkowski() {
			square( width - 2 * radius_corner );
			circle( radius_corner );
		}
}

WIDTH=mm(1.362);
NOTCH_WIDTH=mm(0.735);

module lengthwise_notch() {
    linear_extrude(mm(2))
        polyedge([[0, 0, mm(0.15)], [NOTCH_WIDTH, 0, mm(0.15)], [NOTCH_WIDTH, mm(1)], [0, mm(1)]]);
}

module screw_hole() {
    // eyeball rotation to make it normal to wall
    rotate([-3, 90, 0])
        translate([0, 0, mm(1)])
            cylinder(h=mm(1), d=mm(0.133));
}

module rounder() {
    
    lug_width = mm(0.33);
    rotate([-3, 90, 0]) {
        difference() {
            cube([lug_width, lug_width, lug_width]);
                
            translate([lug_width/2, 0, -1])
                cylinder(h=mm(2), d=lug_width);
        }
    }
}

difference() {
    linear_extrude(WIDTH) {
        polyedge([[0,0, 0.2], [-mm(0.085), mm(0.085), 0.2], [mm(0.59), mm(0.57), 0.2], 
        [mm(0.59), mm(0.27), 0.4], [mm(1.385+0.04), mm(0.22), mm(0.1)], [mm(1.35+0.04), mm(0.7)], 
        [mm(1.6), mm(0.713)], [mm(1.64), mm(0.12), mm(0.15)], [mm(0.29), mm(0.21), 0.4], [0, 0]]);
    }

    translate([mm(-0.25), mm(0.35), NOTCH_WIDTH+(WIDTH-NOTCH_WIDTH)/2])
        rotate([0,90,0])
            lengthwise_notch();
    
    translate([mm(-0.25), mm(0.35), NOTCH_WIDTH+(WIDTH-NOTCH_WIDTH)/2])
        rotate([0,90,0])
            linear_extrude(mm(1))
                polyedge([[0, 0, 0.5], [NOTCH_WIDTH, 0, 0.5], [NOTCH_WIDTH, mm(1)], [0, mm(1)]]);

    
    translate([0, mm(0.485), mm(0.15)])
        screw_hole();

    translate([0, mm(0.485), mm(1.195)])
        screw_hole();
    
    // fudge the z translation a bit to avoid overhang
    translate([mm(1.32), mm(0.7)-mm(0.33)/2, mm(0.32)])
        rounder();
    
    translate([mm(1.32), mm(0.7)-mm(0.33)/2, mm(0.32) + (mm(1.195) - mm(0.15))])
        rounder();
        
    // cutout for top aluminum extrusion on plugin
    translate([mm(0.85)-mm(1.5), mm(1), mm(1.295)])
        rotate([90, 0, -3])
            linear_extrude(mm(2))
                polyedge([[0, 0, 1], [mm(1.5), 0, 1], [mm(1.5), mm(1)], [0, mm(1)]]);
}





//    translate([mm(1.32), mm(0.7)-mm(0.32)/2, mm(0.32)])
//        rounder();

//screw_hole();

/*
difference() {

    cube([mm(2.7), mm(2), mm(0.6)]);
    
    // slide over by wall thickness and up by bottom thickness
    translate([mm(2.7-2.52)/2, -0.01, mm(0.18)])
        cube([mm(2.52), mm(1.9), mm(1)]);

    // spring channel; over by wall thickness
    translate([mm(2.7-2.52)/2, -0.01, mm(0.088)])
        cube([mm(0.38), mm(1.9), mm(1)]);
    
    // spring channel; over full width - channel width - wall thickness
    translate([mm(2.7)-mm(0.38) - mm(2.7-2.52)/2, -0.01, mm(0.088)])
        cube([mm(0.38), mm(1.9), mm(1)]);

    translate([mm(0.288), mm(2.5), mm(0.35)]) {
        rotate([90, 0, 0])
            cylinder(h=mm(3), d=mm(0.16), center=false);
    }
    
    translate([mm(2.405), mm(2.5), mm(0.35)]) {
        rotate([90, 0, 0])
            cylinder(h=mm(3), d=mm(0.16), center=false);
    }

    // back cutout
    translate([mm(2.7-0.85)/2, mm(2.5), mm(0.18)])
        rotate([90, 0, 0])
            linear_extrude(mm(2))
                rounded_square(mm(0.85), mm(0.075));
    
    
    // side cutouts
    translate([mm(-0.25), mm(-0.01), mm(0.75+0.19)])
        rotate([0, 90, 0])
            linear_extrude(mm(3))
                rounded_square(mm(0.75), mm(0.075));
    translate([mm(-0.25), mm(-0.5), mm(0.19)])
        cube([mm(3), mm(0.75), mm(1)]);
   


}

*/


// Copyright (c) 2024 Robert Eisele ( https://raw.org ). All rights reserved.
// Licensed under the MIT license.

// https://raw.org/code/openscad-polygons-with-rounded-corners/


// Example: polyedge([ [x, y, t], ...]);
// The parameter t has the following options:
// = 0: If t is zero (or left out), the edge is becoming a normal sharp edge like in polygon()
// > 0: If t is positive, the edge will get a round corner with radius t
// < 0: If t is negative, the edge will get an inset of length -t from the original edge


function normalize (v) = v / norm(v);
function sgn(a, b) = sign(a[0] * b[1] - a[1] * b[0]);

module polyedge(pts, $fn=$fn) {

    polygon([for (L1 = [
        for (i = [1 : len(pts)])
        let(
            f = $fn == 0 ? 10 : $fn,
            A = pts[(i - 1)],
            B = pts[(i + 0) % len(pts)],
            C = pts[(i + 1) % len(pts)],

            r = B[2],
            S = [B[0], B[1]],
            a = normalize([A[0] - B[0], A[1] - B[1]]),
            b = normalize([C[0] - B[0], C[1] - B[1]]))

             (len(B) == 2 || B[2] == 0)
                ? [ S ]
                : (r < 0 
                    ? [ S - a * r, S - b * r ]
                    : [let(
                        w = r * sqrt(2 / (1 - a * b) - 1),
                        X = a * w,
                        Y = b * w,
                        M = (a + b) * (r / sqrt(1 - pow(a * b, 2))),
                        b1 = atan2(X[1] - M[1], X[0] - M[0]),
                        b2 = atan2(Y[1] - M[1], Y[0] - M[0]),
                        phi = sgn(a, b) * (sgn(a, b) * (b1 - b2) + 360) % 360,
                        segs = ceil(abs(phi) * f / 360)) 
                            for (j = [0 : segs]) 
                                B + M + [
                                    r * cos(b1 - j / segs * phi), 
                                    r * sin(b1 - j / segs * phi)]])]) for (L2 = L1) L2]); 
}
