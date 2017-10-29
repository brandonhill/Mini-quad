
include <_conf.scad>;

module _X_diff_frame_ant_wire_hole(
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

module diff_stock(
		l,
		dim = BOOM_DIM,
		center = true,
		offset = 0,
	) {
	translate([center ? 0 : l / 2, 0, dim[2] / 2])
	cube([l + offset * 2, dim[1] + offset * 2, dim[2] + offset * 2], true);
}

module diff_booms(
		dim = BOOM_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		offset = 0,
	) {
	pos_booms(offset = clamp_width + TOLERANCE_FIT + (BOOM_LENGTH_NAT - BOOM_LENGTH))
	diff_stock(l = dim[0], center = false, offset = offset);
}

module diff_struts(
		all = true,
		dim = STRUT_DIM,
		offset = 0,
	) {
	pos_struts(all = all)
	diff_stock(l = dim[0], offset = offset);
}

module diff_frame_stock(all = true) {
	diff_booms();
	diff_struts(all = all);
}

module pos_ant(
		pos = ANT_POS,
		rot = ANT_ROT,
		z = true,
	) {
	translate([pos[0], pos[1], z ? pos[2] : 0])
	rotate(rot)
	children();
}

module pos_booms(
		motor_angle = BOOM_ANGLE,
		offset = 0,
		reflect = [true, true], // [x, y]
	) {

	reflect(x = reflect[0] ? [-1, 1] : false, y = reflect[1] ? [-1, 1] : false)
	rotate([0, 0, motor_angle])
	translate([offset, 0])
	children();
}

module pos_camera(
		pos = CAM_POS,
		rot = CAM_ROT,
		z = true,
	) {
	translate([pos[0], pos[1], z ? pos[2] : 0])
	rotate(rot)
	children();
}

module pos_motor(i = 1) {
	translate(SIZE / 2 * i)
	children();
}

module pos_motor_screws(
		boom_angle = BOOM_ANGLE,
		mount_screw_spacing = MOTOR_SCREW_SPACING,
	) {
	pos_motor()
	for (i = [0 : 3])
	rotate([0, 0, 45 + boom_angle + 90 * i])
	hull() {
		translate([mount_screw_spacing[0] / 2, 0])
		children();
		translate([mount_screw_spacing[1] / 2, 0])
		children();
	}
}

module pos_motors() {
	reflect()
	pos_motor()
	children();
}

module pos_struts(
		all = false,
		dim = STRUT_DIM,
		motor_mount_rad = MOTOR_MOUNT_RAD,
		pos = STRUT_POS,
		show = [true, true],
	) {

	// x (back)
	if (show[0])
	reflect(y = false, x = (all ? [-1, 1] : false))
	translate([pos[0], 0])
	rotate([0, 0, 90])
	children();

	// y (sides)
	if (show[1])
	reflect(x = false)
	translate([0, pos[1]])
	children();
}

module shape_booms(
		dim = BOOM_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		offset = 0,
	) {
	pos_booms(offset = clamp_width + TOLERANCE_FIT + (BOOM_LENGTH_NAT - BOOM_LENGTH))
	translate([dim[0] / 2, 0])
	square([dim[0] + offset * 2, dim[1] + offset * 2], true);
}

module shape_frame_stock() {
	shape_booms();
	shape_struts();
}

module shape_struts(
		all = true,
		dim = STRUT_DIM,
		offset = 0,
	) {
	pos_struts(all = all)
	square([dim[0] + offset * 2, dim[1] + offset * 2], true);
}
