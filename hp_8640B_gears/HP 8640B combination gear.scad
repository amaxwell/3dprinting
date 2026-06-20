//
// Copyright (c) 2026 Adam R. Maxwell
//
// Combination gear for HP 8640B. Printed in PETG on an Ender 3 with 0.4mm
// nozzle. You may have to tweak BORE and play with the clearance parameter
// depending on your printer. I did not use the brass bushing on this gear,
// as it's maybe seeing a few revolutions per year in my 8640B. YMMV.
// 

include <BOSL2/std.scad>
include <BOSL2/gears.scad>

function mm(inches) = inches * 25.4;
$fn=200;

BORE = mm(0.268);


union() {
translate([0, 0, mm(0.196)]) {
    
    // outer dia of bevel = 0.769"
    // pitch diameter of bevel gear is referenced to outer end of teeth
    // 0.769*pi/36*25.4 = 0.06707
    // mod = 0.769*25.4/36
    // 0.064

    cpb = mm(0.769) * PI / 36;
    bevel_gear(
        circ_pitch=cpb, teeth=36, mate_teeth=18, face_width=mm(0.140),
        shaft_diam=BORE, spiral=0, cutter_radius=0,
        backing=mm(0.14), cone_backing=false, clearance=0.4, pressure_angle=14.5);
    }

    //0.939" 1.036"
    // adding 0.005" fudge factor, at least for 0.4 mm nozzle
    cps = mm((1.037 + 0.970)/2 + 0.005) * PI / 48;
    spur_gear(circ_pitch=cps, teeth=48, thickness=mm(0.130), shaft_diam=BORE,
    clearance=0.4, pressure_angle=14.5, profile_shift=0);
}