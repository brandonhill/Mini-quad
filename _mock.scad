
include <_conf.scad>;
use <_setup.scad>;
use <antenna mount.scad>;
use <canopy.scad>;
use <camera mount.scad>;
use <frame.scad>;
use <motor mount.scad>;

print(["SIZE_DIA = ", SIZE_DIA, ", SIZE = ", SIZE, ", MOTOR_ANGLE = ", MOTOR_ANGLE, ", BOOM_FRAME_ANGLE = ", BOOM_FRAME_ANGLE, ", PROPS = ", PROP_RAD * 2 / MMPI, "\"/", PROP_RAD * 2, "mm"]);

print(["Booms = ", [BOOM_LENGTH, BOOM_HEIGHT, BOOM_THICKNESS]]);
print(["Struts = ", [STRUT_LENGTH, BOOM_HEIGHT, BOOM_THICKNESS]]);

//*
mock_battery();

translate([0, 0, LANDING_GEAR_HEIGHT]) {
// 	*
// 	translate([0, 0, -10])
	union() {
		pos_booms()
		mock_boom(BOOM_LENGTH);

		pos_struts()
		mock_strut(STRUT_LENGTH);
	}

// 	*
	%
//	show_half()
	canopy();

// 	*
	frame();

// 	*
	translate(POS_FRAME_ACC_BACK)
	antenna_mount()
	% 5g_cp_antenna(50);

// 	*
	translate(POS_FRAME_ACC_FRONT)
	camera_mount()
	mock_camera();

// 	*
	translate([0, 0, FRAME_PLATE_THICKNESS + STACK_POS[2]])
	mock_stack();
}

// *
pos_motors() {
	motor_mount();

	translate([0, 0, BOOM_HEIGHT + LANDING_GEAR_HEIGHT]) {//+ MOTOR_MOUNT_MIN_THICKNESS]) {
		mock_motor();

		translate([0, 0, sum(MOTOR_DIM[1]) - MOTOR_DIM[1][2] / 2]) {
			mock_prop();
		}
	}
}

module mock_battery(dim = BATTERY_DIM) {
	translate([0, 0, dim[2] / 2])
	% cube(dim, true);
}

module mock_boom(l, h = BOOM_HEIGHT, t = BOOM_THICKNESS) {
	translate([l / 2, 0, h / 2])
	% cube([l, t, h], true);
}

module mock_camera(
		angle = CAM_ANGLE,
		housing_dim = CAM_HOUSING_DIM,
		lens_dim = CAM_LENS_DIM,
		pivot_offset = CAM_PIVOT_OFFSET,
	) {

	%
	rotate([0, -angle, 0]) // pivot
	translate([-pivot_offset, 0]) // move back to pivot
	cam_runcam_swift_micro();
}

module mock_motor(d = MOTOR_DIM, shaft_r = MOTOR_SHAFT_RAD) {
// 	% cylinder(h = h, r = r);
	motor_generic(
		height = d[1][1],
		rad = d[0] / 2,
		mount_arm_width = 0,
		mount_height = d[1][0],
		mount_rad = d[0] / 2,
		mount_holes = 0,
		mount_hole_rad = 2,
		mount_hole_thickness = 0,
		shaft_height = d[1][2],
		shaft_rad = shaft_r,
		col_bell = COLOUR_GREY_DARK,
		col_mount = COLOUR_GREY
	);
}

module mock_prop(r = PROP_RAD) {
	%
	rotate_extrude()
	translate([r, 0])
	circle(0.5);
}

module mock_stack(dim = STACK_DIM) {
// 	%
	translate([0, 0, dim[2] / 2])
	cube(dim, true);
}

module mock_strut(l, h = BOOM_HEIGHT, t = BOOM_THICKNESS) {
	%
	translate([0, 0, h / 2])
	cube([l, t, h], true);
}

module pos_motors() {
	for (x = [-1, 1], y = [-1, 1])
	scale([x, y])
	translate(SIZE / 2)
	children();
}
