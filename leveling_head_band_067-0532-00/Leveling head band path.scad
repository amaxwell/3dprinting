include <BOSL2/std.scad>
include <BOSL2/rounding.scad>

function mm(inches) = inches * 25.4;

$fn=200;

/* Not perfect; there should be more rounding on the corners, in particular. 
   However, it's good enough to pass. If I try shrinking it a little more,
   the screw lugs start to poke through, and I don't feel like futzing around
   with those to improve it.
   */
function band_path() = smooth_path(square([mm(2.05 + 0.060),mm(0.95 + 0.035)]), uniform=true, relsize=0.06, splinesteps=70, closed=true);

//color("green")
// stroke(square([mm(2.05),mm(0.95)]), closed=true, width=0.1);

module test_path() {
    linear_extrude(5) {
        bp = band_path();
        stroke(bp, width=2);
    }
}

//test_path();

/*
right(mm(0.09)) {
polygon(xflip([[mm(0.025), 0],
        [mm(0.025), mm(0.025)],
        [0, mm(0.025)],
        [0, mm(0.130)],
        [mm(0.025), mm(0.130)],
        [mm(0.025), mm(0.250)],
// top outside edge
        [mm(0.065), mm(0.250)],
        [mm(0.090), 0]]));
}
*/

lug_size = mm(0.20);
module corner_lug()
{
  
   union() {
        left(lug_size/2) square([lug_size/1.1, lug_size/1.1], center=true);
        fwd(lug_size/2) square([lug_size/1.1, lug_size/1.1], center=true);
        circle(d=1.1*lug_size);
   }

}

union() {
    
    // main band section
    path_extrude2d(band_path(), caps=false, closed=true) {
       right(mm(0.09)) {
           
           // cross-section of the band, looking with inside to the left
           polygon(xflip([[mm(0.025), 0],
            [mm(0.025), mm(0.025)],
            [0, mm(0.025)],
            [0, mm(0.130)],
            [mm(0.025), mm(0.130)],
            [mm(0.025), mm(0.250)],
            // top outside edge
            [mm(0.065), mm(0.250)],
            [mm(0.090), 0],
            [mm(0.025), 0]]));
       }

    }

    /*
        The rest of this insanity is getting screw lugs in the
        corners. There's likely a better way to do this, but it
        looks okay for now.
    */

    // 3/32" was just a bit undersized
    screw_hole = mm(0.125);
    
    right(lug_size/2) back(lug_size/2) 
        translate([0, 0, mm(0.025)]) linear_extrude(mm(0.130 - 0.025)) {
            difference() {
                union() {
                    circle(d=lug_size);
                    right(mm(0.085)) back(mm(0.085)) corner_lug();
                }
            right(mm(0.050)) back(mm(0.050)) circle(d=screw_hole);
            }
        }

    right(mm(2.05 + 0.070) - lug_size / 2) back(lug_size/2)
        translate([0, 0, mm(0.025)]) linear_extrude(mm(0.130 - 0.025)) {
            difference() {
                union() {
                    circle(d=lug_size);
                    zrot(90) right(mm(0.085)) back(mm(0.085)) corner_lug();
                }
            left(mm(0.050)) back(mm(0.050)) circle(d=screw_hole);
            }
        }
    
    right(lug_size/2) back(mm(0.95 + 0.045) - lug_size / 2) 
        translate([0, 0, mm(0.025)]) linear_extrude(mm(0.130 - 0.025)) {
            difference() {
                union() {
                    circle(d=lug_size);
                    zrot(270) right(mm(0.085)) back(mm(0.085)) corner_lug();
                }
                right(mm(0.050)) fwd(mm(0.050)) circle(d=screw_hole);
            }
        }
    
    back(mm(0.95 + 0.045) - lug_size/2) right(mm(2.05 + 0.070) - lug_size/2)     translate([0, 0, mm(0.025)]) linear_extrude(mm(0.130 - 0.025)) {
            difference() {
                union() {
                    circle(d=lug_size);
                    zrot(180) right(mm(0.085)) back(mm(0.085)) corner_lug();
                }
                left(mm(0.050)) fwd(mm(0.050)) circle(d=screw_hole);
            }
     
        }
}
