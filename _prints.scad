
include <_conf.scad>;
use <antenna mount.scad>;
use <canopy.scad>;
use <camera mount.scad>;
use <frame.scad>;
use <motor mount.scad>;

echo(str("Booms = ", [BOOM_LENGTH, BOOM_HEIGHT, BOOM_THICKNESS]));
echo(str("Struts = ", [STRUT_LENGTH, BOOM_HEIGHT, BOOM_THICKNESS]));

$fs = 0.5;

// !
rotate([0, 90])
antenna_mount();

// !
rotate([0, -90])
camera_mount();

!
// rotate([0, 180 + CANOPY_ANGLE_TOP]) // this is no good for the lip :(
canopy();

// !
frame();

// !
rotate([0, 180])
motor_mount();
