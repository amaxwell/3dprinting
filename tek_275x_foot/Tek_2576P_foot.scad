include <BOSL2/std.scad>

function mm(inches) = inches * 25.4;
$fn=200;

// #6 screw
HEAD_DIA=mm(0.290);
SCREW_DIA=mm(0.175);
HOLE_CENTERS=mm(1.5);

module hole()
{
    union() {
        translate([0, 0, 50]) {
            // screw thread thru hole
            cylinder(h=100, d=SCREW_DIA, center=true);
            
            // counterbore for screw head
            translate([0, 0, mm(0.225)]) {
                cylinder(h=100, d=HEAD_DIA, center=true);
            }
        }
    }
}

difference() {

  diff() {
    prismoid(size1=[mm(3/4),mm(2.25)], size2=[mm(3/4-1/16),mm(2.25-1/16)], h=mm(1/2), rounding=1.2)
    
    edge_profile(TOP, excess=20)
        mask2d_roundover(height=1.2, mask_angle=$edge_angle);
    
  }
  

    translate([mm(0.125), -HOLE_CENTERS/2, -0.1])
        hole();
    translate([mm(0.125), HOLE_CENTERS/2, -0.1])
        hole();
}