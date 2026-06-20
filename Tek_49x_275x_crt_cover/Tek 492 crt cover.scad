

difference() {
    cube([145+2+2, 130+2, 10+2+2], center=true);
    translate([0, 2, 0]) {
        cube([145, 130+2, 10], center=true);
        translate([0, 0.01, 3])
            cube([145-2, 130-2, 10], center=true);
    }
}