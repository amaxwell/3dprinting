//import("/Users/amaxwell/Downloads/ST7735 1.8 tft - 4920374/files/st7735_v2.stl", convexity=3);

// anything referring to "width" is the short dimension
// anything referring to "length" is the long dimension
// I should probably fix that because I had to write this comment

use <roundedcube.scad>
use <Round-Anything/polyround.scad>

module notch()
{
    linear_extrude(20, center=false)
        square([9, 6.6], center=false);
}

module base()
{
    difference() {
        
        base_rad = 3.0;
        radii_points = [
            [5,22.5,0], // lower left corner of base
            [5, 32, base_rad], 
            [24, 38, base_rad], 
            [31, 31, base_rad], 
            [110, 31, base_rad], 
            [117, 38, base_rad], 
            [136, 32, base_rad], 
            [136, 22.5, 0]
        ];
        polyRoundExtrude(
            radii_points,
            6,   // height
            1.0, // top radius
            0.0, // bottom radius; doesn't print if this face is on the bed
            fn=50);

        // x=15 (box width = 9, offset = 6) will be left edge of flange
        translate([6, 22.4, 3]){
            notch();
        }
        
        // x=126 will be right edge of flange
        translate([126, 22.4, 3]){
            notch();
        }
    }
}

 module cylinder_outer(height,radius,fn){
   fudge = 1/cos(180/fn);
   cylinder(h=height,r=radius*fudge,$fn=fn);
}

module bevel() {
    rotate([90, 0, 0]) {
        rotate(a=[0, 90, 0]) {
            linear_extrude(150, center=false)
                polygon([[0,0],[2.5,0],[0,2.5]]);
        }
    }
}
   
difference() {
    
    // top of flange is 13.5 + 2mm
    flange_el = 13.5;

    // join the base, web, and flange
    union() {

        base();
        
        // web up to middle-ish of flange
        translate([15, 22.5, 0])
            roundedcube([111, 6, 15.5], false, 1, "ymax");
    
        // flange without holes
        translate([15, 5.5, flange_el]){
            roundedcube([111, 22.5, 2], false, 0.5, "zmax");
        }
    
    }

    // cavity in web
    translate([15 + 3, 22.4, 2]){
        linear_extrude(flange_el - 2, center=false)
            square([104.5, 2.6], center=false);
    }
    
    // holes in flange
    hole_dia = 5.6; // 0.25"
    translate([24.5, 16.5, 10]){
        cylinder_outer(25, hole_dia/2, 30);
    }
    
    translate([116.5, 16.5, 10]){
        cylinder_outer(25, hole_dia/2, 30);
    }
    
    translate([0, 5.5, flange_el - 1])
        bevel();
}

