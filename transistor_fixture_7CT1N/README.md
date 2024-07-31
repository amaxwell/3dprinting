## What is this

I wanted a fixture of sorts to test transistors on my 7CT1N, so came up with another 3D printer project. The idea was to compare transistors from a 7B70 that I was trying to repair, and have sockets instead of mucking about with grabber leads.

## Other materials

- 3PDT toggle switch
- three panel mount banana plugs (Mouser #530-108-0753-102)
- four transistor sockets (Mouser #575-91743103)
- insulated hookup wire

Note that the transistor sockets I used have a little nub on them for indexing. I snipped that off with dykes and used a bit of clear silicone to hold the sockets in place in the lid. Various other adhesives would work, but silicone is weak enough to allow reusing sockets if you screw up and have to pop them back out.

## Labels and bugs

The socket labels are not great. The "embossed" version allows you to print with the top face on the build plate, but the characters didn't print cleanly for me. The raised version looks better, but print times are a lot longer because you need to print a massive amount of support.

## OpenSCAD dependencies

If you look at the code, the heavy lifting for this is obviously done by Ezra Reynolds' fantastic Button Box Generator. I spent a Saturday and a lot of filament modifying it to add holes in the appropriate places, add labels, and get dimensions correct.

If you regenerate the STL, you'll need to install the Mesh Tools extension in Cura to break the model apart. This allows you to reposition the face and back appropriately. YMMV with other slicers.
