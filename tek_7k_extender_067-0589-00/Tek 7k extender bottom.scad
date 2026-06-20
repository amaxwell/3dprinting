//
// Licensed under MIT license
//
// Copyright (c) 2025 Adam R. Maxwell
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

}


