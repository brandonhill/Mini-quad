
include <_setup.scad>;

use <antenna mount.scad>;
use <canopy.scad>;
use <camera mount.scad>;
include <frame.scad>;
use <motor mount.scad>;

$fs = 0.5;

echo(str("$fa = ", $fa, ", $fn = ", $fn, ", $fs = ", $fs));
echo(str("Booms = ", BOOM_DIM));
echo(str("Struts = ", STRUT_DIM));

*rotate([180, 0])
canopy();

frame_bot();

*translate([0, 0, -FRAME_HEIGHT + FRAME_CLAMP_DEPTH + FRAME_CLAMP_THICKNESS])
frame_top();

// front motor clamp (left/right)
*mirror([0, 1]) // for right
rotate([0, 0, 180 - BOOM_ANGLE])
pos_motor(i = -1, z = false)
motor_clamp(struts = [true, false]);

// rear motor clamp (x2)
*rotate([0, 0, 180 - BOOM_ANGLE])
pos_motor(i = -1, z = false)
motor_clamp();

// front motor mount (left/right)
*mirror([0, 1]) // for left
rotate([0, 0, -BOOM_ANGLE])
translate([0, 0, FRAME_HEIGHT + FRAME_CLAMP_NUT_DIM[2]])
mirror([0, 0, 1])
pos_motor(i = -1, z = false)
motor_mount(struts = [true, false]);

// rear motor mount (x2)
*rotate([0, 0, 180 - BOOM_ANGLE])
translate([0, 0, FRAME_HEIGHT + FRAME_CLAMP_NUT_DIM[2]])
mirror([0, 0, 1])
pos_motor(i = -1, z = false)
motor_mount();
