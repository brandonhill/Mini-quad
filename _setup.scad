
include <_conf.scad>;

module pos_booms() {
	for (x = [-1, 1], y = [-1, 1])
	scale([x, y])
	translate(FRAME_DIM / 2)
	rotate([0, 0, BOOM_FRAME_ANGLE])
	translate([FRAME_WALL_THICKNESS + TOLERANCE_CLOSE, 0])
	children();
}

module _X_pos_frame_accessory_front() {
	translate(POS_FRAME_ACC_FRONT)
	children();
}

module pos_struts() {
	for (y = [-1, 1])
	scale([1, y])
	translate([0, SIZE[1] / 2 + MOTOR_MOUNT_RAD + MOTOR_MOUNT_OUTSET - FRAME_CLAMP_THICKNESS - BOOM_THICKNESS / 2 - TOLERANCE_CLOSE])
	children();
}

module shape_booms(l = BOOM_LENGTH, t = BOOM_THICKNESS) {
	pos_booms()
	translate([l / 2, 0])
	square([l, t], true);
}

module diff_booms(l = BOOM_LENGTH, t = BOOM_THICKNESS) {
	shape_booms(l, t);
}

module diff_frame_ant_wire_hole(
		ant_wire_hole_rad = ANT_WIRE_HOLE_RAD,
		//frame_dim = FRAME_DIM,
		l = max(ANT_MOUNT_THICKNESS, FRAME_WALL_THICKNESS) * 2 + 1,
		plate_thickness = FRAME_PLATE_THICKNESS,
		wall_thickness = FRAME_WALL_THICKNESS,
	) {

	translate([POS_FRAME_ACC_BACK[0] + ANT_MOUNT_THICKNESS / 2, 0, plate_thickness + ant_wire_hole_rad])
	rotate([0, 90])
	cylinder(h = l, r = ant_wire_hole_rad, center = true);
}

module diff_struts(l = STRUT_LENGTH, t = BOOM_THICKNESS) {
	pos_struts()
	square([l, t], true);
}
