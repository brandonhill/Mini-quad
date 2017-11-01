
include <_setup.scad>;

include <antenna mount.scad>;
include <canopy.scad>;
include <camera mount.scad>;
include <frame.scad>;
include <motor mount.scad>;

FINAL_RENDER = true;

$fs = FINAL_RENDER ? 0.5 : $fs;

/* Last rendered using:
TOLERANCE_CLOSE = 0.15;
TOLERANCE_FIT = 0.2;
TOLERANCE_CLEAR = 0.25;
*/

*test_threads();

// just for fun
test_screws();



module test_screws() {
	// tolerance test on threads
	screw_dim = SCREW_M3_SOCKET_DIM;
	h = 5;
	sep = screw_dim[1] + 1;
	tol = [0, TOLERANCE_CLOSE, TOLERANCE_FIT, TOLERANCE_CLEAR];

	translate([-sep * (len(tol) - 1) / 2, 0])
	rotate([180, 0])
	for (i = [0 : len(tol) - 1])
	translate([sep * i, 0])
	screw(screw_dim, h, THREAD_PITCH_M3_COARSE, offset = tol[i], threaded = true);
}

module test_threads() {

	// tolerance test on threads
	d = 3; // M3
	h = 5;
	sep = 5;
	tol = [0, TOLERANCE_CLOSE, TOLERANCE_FIT, TOLERANCE_CLEAR];

	difference() {

		cube([sep * len(tol), sep, h], true);

		translate([-sep * (len(tol) - 1) / 2, 0])
		for (i = [0 : len(tol) - 1])
		translate([sep * i, 0])
		thread_iso_metric(d + tol[i] * 2, h + 0.2, THREAD_PITCH_M3_COARSE, internal = true);
	}
}
