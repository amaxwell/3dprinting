width=0.175*25.4;

linear_extrude(0.5*25.4) {
    polygon([[0,0], [width,0], [width, 0.154*25.4], [0, 0.168*25.4]]);
}

linear_extrude(0.065*25.4) {
    polygon([[0,0], [width,0], [width, 0.180*25.4], [0, 0.206*25.4]]);
}

translate([0, 0, (0.5 - 0.065)*25.4]) {
    linear_extrude(0.065*25.4) {
    polygon([[0,0], [width,0], [width, 0.180*25.4], [0, 0.206*25.4]]);
    }
}