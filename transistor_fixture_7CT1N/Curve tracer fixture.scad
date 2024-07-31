// Button Box Generator

// Over the years, I keep encountering the need for small, 3D-printed boxes to control computer/device.
// In practical terms, this usually means a small box with arcade buttons and something like a Trinket
// microcontroller or iPac gamepad interface to change button presses into something the computer will understand.

// This is a simple generator for these sorts of boxes, and the lid for these boxes.
// This assumes a "rectangular" (other shapes permitted) box with a sloping face (front to back) 
// in which the buttons are placed.

// Author: Ezra Reynolds
// Email:  Ezra_Reynolds@signalcenters.org

// Version History:
//  2018-11-15 - v.1.0 - First fully functional & parameterized version, pulled from other projects.
//    2019-08-07 - v1.1 - Set Z to 0, so that text is not "free floating"

// ======================== PARAMETERS ===========================================

inch        = 25.4; // 25.4 mm per inch

// Basic Set of Control Points.  Every point is a corner; every point has a screw in the bottom.
points = [[0, 0], [90, 0], [90, 50], [0, 50]];

height1     = 27;   // The height at the front of the part (most negative y)
height2     = 32;   // The height at the rear of the part (most positive y)

corner_r    = 8;    // Determines rounding at corners, edges
thickness   = 3;    // Wall thickness

cable_d     = 0;    // Diameter of data cable, if set 
cable_x     = 0;    // Location of cable hole

screwlug_d  = 6;    // Screw Terminals 
lid_gap     = 0.25; // Gap between lid and body
 
onFace_z    = 0.5;    // Fudge factor - global z adjustment perpindicular to "face" of project
$fn         = 40;   // Circle smoothness factor - set it to 15 for prototyping, ~40 for printing

cutout       = false; // If true, slices model in half for interior viewing
3DPrint      = true;  // If true, turns off "view only" decorations for printing

// Screws (Mounting base to top) parameters
// Assumes using flat-top or bugle headed screws, so the heads will be flush with bottom
screw_hole_d   = 1.5;  // The diameter of the hole in the box to which the lid will attach.
screw_h        = 20;   // The length of the screw shaft
screw_shaft_d  = 2;    // The diameter of the screw shaft
screw_head_d   = 6;    // The diameter of the screw head

screw_offset   = -1;   // Fudge factor on moving screws (and screw holes) in/out from edge of lid

// ======================== DERIVED PARAMETERS =============================================

// This uses a rough centroid calculation (average of the control points) to determine the center of the object.
// In testing this has been close / "good enough", but not exact.  
// However, exact solutions would require knowledge of the order of points in order to calculate tangency.
// This is used primarily for controlling the offset of the screw-holes (e.g. push holes closer to edge).

centroid_x = ave([for (i=points) i.x ]);
centroid_y = ave([for (i=points) i.y ]);
echo ("Centroid = ", centroid_x, centroid_y);

// The depth controls the height along the surface
min_depth = min ([for (i=points) i.y]);
max_depth = max ([for (i=points) i.y]);
depth = max_depth-min_depth;
echo ("min y =", min_depth, " max y=", max_depth, " Depth=", depth);

// ======================== MODULES AND FUNCTIONS ===========================================

// Standard linear interpolation function.  Heights of control points are calculated based on 
// linear interpolation between height1 (assumed to be in the front) and height2.
function interpolate (x0=0, x1=1, y0=0, y1=1, x=0.5) = ((y0 * (x1 - x)) + (y1 * (x-x0))) / (x1-x0);

// ------------------------------------------------------------

// Sum all the points in a vector
function sum(v,i = 0) = i < len(v) ? v[i] + sum(v, i+1) : 0;

// ------------------------------------------------------------

// Average the points in a vector
function ave(v) = sum(v) / len(v);

// ------------------------------------------------------------

module basic_shape(shell=false)
{
    // Create the basic shape, with no indentations or decorations.

    difference()
    {
        minkowski()
        {
            hull()
            {
                // Place domed cylinders at each of the control points.  Each cylinder will have a height 
                // calculated by interpolating between height1 and height2

                for (i=points)
                {
                    translate ([i.x, i.y, 0]) 
                    {
                        c_height = interpolate (min_depth, max_depth, height1, height2, i.y) - corner_r;
                        //echo (i.y, c_height);

                        cylinder (r=corner_r - thickness, h=c_height );
                        translate ([0, 0, c_height]) sphere (r= corner_r - thickness);

                    }   // end translate

                }   // end for

            }   //end hull

            sphere (r= (shell ? 0 : thickness), $fn=20);// If shell=true, essentially don't do minkowski
        
        }//end minkowski
        
        // Trim everything below z=0 (since dealing with minskowski)
        translate ([0, 0, -2000]) cube (4000, center=true);

    }   // end difference

}   // end basic_shape()

// ------------------------------------------------------------

module lid_outline(eps = 0.25)
{
    // From the bottom shape, create a shape for the lid.

    // Larger values of eps make for a smaller lid, this allows for more precise fitting based
    // on differences with 3D printers.

    offset (r=-(thickness+eps))
        projection () basic_shape();

} // end lid_outline()

// ------------------------------------------------------------

module shell_outline( flange = 3)
{
    // Create an smaller shape (similar to basic shape), but for purposes of subtracting to make a shell.
    
    // This also creates the screw posts at each corner.
    // It then uses the double offset to smoothly blend the shapes.

    offset (r=+flange) offset(r=-flange)
        difference()
        {
            // Start with the lid outline
            lid_outline(0);
    
            // Create cutouts for the screw standoffs
            for (i = points)
                translate ([i.x - ((i.x < centroid_x ? -1:1) * screw_offset), 
                            i.y - ((i.y < centroid_y ? -1:1) * screw_offset), 
                            0]) 
                    circle (d=screwlug_d);
            
        }   // end difference

}   // End shellOutline()

// ------------------------------------------------------------

module onFace(height1, height2, depth, x = 0, y = 0)
{
    // Given Parameters of a sloped face defined in (x,y) and rising in Z, place children on sloped face
    //      height1 = height of front edge
    //      height2 = height of rear edge
    //      length  = length of between front and rear
    //       x    = offset positioning in x (optional)
    //       y    = offset positioning in x (optional)
    //      { ... } = children to be positioned

    slope = (height2 - height1) / depth;
    face_angle = (slope != 0 ? (atan (slope)) : 0);
    
    // Optional Printing of calculated angle
    //echo ("module onFace(): Face Angle=", face_angle);

    translate ([0, 0, onFace_z])
    {
        translate ([x, cos(face_angle) * y, height1 + sin(face_angle) * y])
            rotate ([face_angle, 0, 0]) children();
    
    } // end translate
            
}   // end onFace()

// -----------------------------------------------------------------------------------------

module button()
{
    // Create a rough model of a button.
    // Rough means not exact, useful for visualizing the project and boring holes in the face
    
    // Note that this has a margin built in, so this can be used for boring holes.

    // Some buttons use spring clips, some use plastic nuts (that use a lot more space below-deck).
    // Don't make the edges of the box slap up against the button if using the plastic nuts

    // Button Type: Seimitsu-PS-15 low profile
    // Example: https://www.focusattack.com/buttons/seimitsu/30mm/ps-15-pushbutton/

    button_d       = 6.35;  // Diameter of Arcade Button shaft (and thus the needed hole)
    button_margin  = 1;     // Manufacturing Tolerance so button will fit in
    button_below   = 22.7;  // Button distance below deck
    button_above   = 7.1;   // Button distance below deck
    
    // Cut the hole / create the button below.
    translate ([0, 0, -button_below + 0.05])
    cylinder (d = button_d + button_margin, h=button_below);  

    // Create the lip on the top
    translate ([0, 0, -2]) cylinder (d = button_d + 4, h = 3);
    
    // Create the "button" on the top
    cylinder (d = button_d*.8, h = button_above);

}   // end button

// ----------------------------------------------------------------------

module lid()
{
    // Create the lid/base cover for the project

    difference()
    {
        linear_extrude (thickness) lid_outline(lid_gap);

        // Create holes for screws
        for (i = points) 
        {
            translate ([i.x - ((i.x < centroid_x ? -1:1) * screw_offset), 
                        i.y - ((i.y < centroid_y ? -1:1) * screw_offset), 
                        -0.1]) 
                cylinder (d2=screw_hole_d, d1=screw_head_d, h=thickness+0.2);

        }   // end for

    }   // end difference

}   // end lid()


// ======================== CREATE 3D PARTS ===========================================

// Create the Enclosure. 
difference()
{
    basic_shape();

    // Create the inset lip for the lid
    translate ([0, 0, -0.1]) linear_extrude (thickness) lid_outline(eps=0);

    // Create Shell by removing the intersection of the shell outline with smaller basic_shape
    intersection()
    {
        // Scale down the original
        basic_shape(shell=true);

        // Extrude the rounded bottom profile with screw standouts in the corners
        translate ([0, 0, -10]) linear_extrude(1000, convexity=10) shell_outline();

    }   // end intersection
    
    // Create holes for screws into the standoffs
    for (i = points) 
    {
        translate ([i.x - ((i.x < centroid_x ? -1:1) * screw_offset), 
                    i.y - ((i.y < centroid_y ? -1:1) * screw_offset), 
                    -0.1]) 
        cylinder (d=screw_hole_d, h=interpolate (min_depth, max_depth, height1, height2, i.y) - corner_r - thickness);

    }   // end for

    // Optional Cutaway (greatly helps with troubleshooting to get a cross-sectional view)
    if (cutout) translate ([-200, -100, -10]) cube (200, 200, 200);

    // Carve Button Holes perpindicular to the face
	onFace (height1, height2, depth) 
	{
		translate ([20, 15, 0]) color ("green") button();
		translate ([70, 15, 0]) color ("red") button();
        
        translate ([20, 35, 0]) color ("green") button();
		translate ([70, 35, 0]) color ("red") button();
        
        translate ([45, 25, 0]) color ("red") button();
	}

    // Carve Data Cable slot
    hull()
    {
        translate ([cable_x, centroid_y, -cable_d]) 
            rotate ([-90, 0, 0]) 
                cylinder (d=cable_d, h=depth);
        
        translate ([cable_x, centroid_y, thickness+cable_d]) 
            rotate ([-90, 0, 0]) 
                cylinder (d=cable_d, h=depth);

    }   // end hull
    
    translate ([centroid_x, depth - thickness/2, height2 - 12])
        rotate ([-90, 0, 0])
            cylinder (d = 3.6, h = thickness * 4);
     translate ([centroid_x - 19.05, depth - thickness/2, height2 - 12])
        rotate ([-90, 0, 0])
            cylinder (d = 3.6, h = thickness * 4);
    translate ([centroid_x + 19.05, depth - thickness/2, height2 - 12])
        rotate ([-90, 0, 0])
            cylinder (d = 3.6, h = thickness * 4);
   
 onFace (height1, height2, depth) {
	translate ([10, 17, -1])
         color ("blue") linear_extrude (2) text ("E", size = 2.5);
 	translate ([10, 14, -1])
         color ("blue") linear_extrude (2) text ("B", size = 2.5);
	translate ([10, 11, -1])
         color ("blue") linear_extrude (2) text ("C", size = 2.5);

	translate ([10, 37, -1])
         color ("blue") linear_extrude (2) text ("C", size = 2.5);
 	translate ([10, 34, -1])
         color ("blue") linear_extrude (2) text ("B", size = 2.5);
	translate ([10, 31, -1])
         color ("blue") linear_extrude (2) text ("E", size = 2.5);
    
    
    translate ([60, 17, -1])
         color ("blue") linear_extrude (2) text ("E", size = 2.5);
 	translate ([60, 14, -1])
         color ("blue") linear_extrude (2) text ("B", size = 2.5);
	translate ([60, 11, -1])
         color ("blue") linear_extrude (2) text ("C", size = 2.5);

	translate ([60, 37, -1])
         color ("blue") linear_extrude (2) text ("C", size = 2.5);
 	translate ([60, 34, -1])
         color ("blue") linear_extrude (2) text ("B", size = 2.5);
	translate ([60, 31, -1])
         color ("blue") linear_extrude (2) text ("E", size = 2.5);
          
}

}   // end difference()

if (!3DPrint)
{
	// Only add these parts for "viewing" not "printing" the model.
	onFace (height1, height2, depth) 
	{
		translate ([20, 20, -0]) color ("green") button();
		translate ([70, 20, -0]) color ("red") button();
	}
}

// These decorations will always be part of the model.


translate ([0, -25, thickness]) rotate ([180, 0, 0]) lid();

// END OF FILE. S.D.G.