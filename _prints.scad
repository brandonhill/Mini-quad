
include <_setup.scad>;
use <antenna mount.scad>;
use <canopy.scad>;
use <camera mount.scad>;
use <frame.scad>;
use <motor mount.scad>;

// Caution! This renders threads on the FC mount posts, and takes a long time
FINAL_RENDER = true;

echo(str("Booms = ", BOOM_DIM));
echo(str("Struts = ", STRUT_DIM));

$fs = FINAL_RENDER ? 0.5 : $fs;

*
rotate([0, 90])
antenna_mount();

*
rotate([0, -90])
camera_mount();

*
// rotate([0, 180 + CANOPY_ANGLE_TOP]) // this is no good for the lip :(
canopy();

*
frame();

//*
frame(top = true);

*
rotate([0, 180])
motor_mount();
