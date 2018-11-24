
include <_conf.scad>;

module diff_booms(
		dim = BOOM_DIM,
		offset = 0,
		z = true,
	) {
	pos_booms(z = z)
	diff_stock(dim = dim, center = false, offset = offset);
}

module diff_shape_booms(
		dim = BOOM_DIM,
		offset = 0,
	) {
	pos_booms(offset = BOOM_LENGTH_NAT - BOOM_LENGTH)
	diff_shape_stock(l = dim[0], dim = dim, center = false, offset = offset);
}

module diff_shape_stock(
		l,
		dim,
		center = true,
		offset = 0,
	) {
	translate([center ? 0 : l / 2, 0])
	square([l + offset * 2, dim[1] + offset * 2], true);
}

module diff_stock(
		dim,
		center = true,
		offset = 0,
	) {
	translate([center ? 0 : dim[0] / 2, 0, dim[2] / 2])
	cube([
		dim[0] + offset * 2,
		dim[1] + offset * 2,
		dim[2] + offset * 2], true);
}

module diff_shape_struts(
		dim = STRUT_DIM,
		offset = 0,
		struts = [true, true],
	) {
	pos_struts(struts = struts)
	diff_shape_stock(l = dim[0], dim = dim, offset = offset);
}

module diff_struts(
		dim = STRUT_DIM,
		offset = 0,
		struts = [true, true],
		z = true,
	) {
	pos_struts(struts = struts, z = z)
	diff_stock(dim = dim, offset = offset);
}

module diff_frame_stock(struts = [true, true]) {
	diff_booms();
	diff_struts(struts = struts);
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
		boom_angle = BOOM_ANGLE,
		outset = BOOM_OUTSET,
		reflect = [true, true], // [x, y]
		z = true,
	) {

	reflect(x = reflect[0] ? [-1, 1] : false, y = reflect[1] ? [-1, 1] : false)
	rotate([0, 0, boom_angle])
	translate([outset, 0, z ? FRAME_CLAMP_THICKNESS : 0])
	children();
}

module pos_buzzer(
		pos = BUZZER_POS,
		rot = BUZZER_ROT,
		z = true,
	) {
	translate([pos[0], pos[1], z ? pos[2] : 0])
	rotate(rot)
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

module pos_frame_nuts(
		boom_dim = BOOM_DIM,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
	) {
	pos_frame_screws()
	translate([0, 0, boom_dim[2] + clamp_thickness * 2])
	children();
}

module pos_frame_screws(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		dim = FRAME_DIM,
		hull = false,
		show = [true, true],
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		reflect = [true, true], // [x, y]
	) {

	module pair() {
		boom_offset = (boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE;
		x_outer = min(dim[0], dim[1]) / 2 / sin(boom_angle); // at frame corner
		x_inner =
			(BATT_STRAP_DIM[0] + screw_dim[0]) / 2 / sin(90 - boom_angle) // at edge of battery strap
			+ boom_offset / tan(90 - boom_angle); // accommodate y (boom) offset

		// front/back facing
		if (show[0])
		translate([x_outer, -boom_offset])
		children();

		// side facing
		if (show[1])
		//translate([x_inner + (x_outer - x_inner) * 0.5, boom_offset])
		translate([x_outer, boom_offset])
		children();
	}

	translate([0, 0, -clamp_thickness])
	pos_booms(reflect = reflect, outset = 0) {
		if (hull) {
			hull()
			pair()
			children();
		} else {
			pair()
			children();
		}
	}

	// alternate: single centre screw (probably too weak)
	*reflect(y = false)
	translate([(BATT_STRAP_DIM[0] + screw_dim[0]) / 2, 0])
	children();
}

module pos_landing_gear(
		boom_dim = BOOM_DIM,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		h = LG_HEIGHT,
		motor_rad = MOTOR_RAD,
		width = LG_WIDTH,
	) {
	pos_booms(reflect = [false, true])
	translate([boom_dim[0] - 15, 0, clamp_thickness + boom_dim[2] / 2 + h])
	rotate([90, 0, 90])
	children();
}

module pos_motor(i = 1, z = true) {
	//translate([0, 0, z ? FRAME_HEIGHT + FRAME_CLAMP_NUT_DIM[2] + MOTOR_SOFT_MOUNT_THICKNESS : 0])
	translate([0, 0, z ? FRAME_HEIGHT + FRAME_CLAMP_NUT_DIM[2] : 0])
	translate(SIZE / 2 * i)
	children();
}

module pos_motor_mounts_front_top() {
	reflect(x = false)
	translate([0, 0, BOOM_DIM[2] + FRAME_CLAMP_THICKNESS + FRAME_CLAMP_THICKNESS])
	scale([1, 1, -1])
	children();
}

module pos_motor_screws(
		boom_angle = BOOM_ANGLE,
		hull = true,
		mount_screw_spacing = MOTOR_MOUNT_RAD,
	) {
	if (hull)
		for (i = [0 : len(mount_screw_spacing) - 1])
		rotate([0, 0, 360 / (len(mount_screw_spacing) * 2) * i])
		reflect()
		hull() {
			translate([min(mount_screw_spacing), 0])
			children();
			translate([max(mount_screw_spacing), 0])
			children();
		}
	else
		rotate([0, 0, BOOM_ANGLE])
		pos_motor_eachine_2204_screws()
		children();
}

module pos_motors(z = true) {
	reflect()
	pos_motor(z = z)
	children();
}

module pos_rx(
		pos = RX_POS,
		rot = RX_ROT,
		z = true,
	) {
	translate([pos[0], pos[1], z ? pos[2] : 0])
	rotate(rot)
	children();
}

module pos_struts(
		pos = STRUT_POS,
		struts = [true, true],
		reflect = [true, false],
		z = true,
	) {

	//warn(["pos_struts", struts]);

	translate([0, 0, z ? FRAME_CLAMP_THICKNESS : 0]) {

		// x (sides)
		if (struts[0])
		reflect(x = false, y = reflect[0] ? [1, -1] : false)
		translate([0, pos[1]])
		children();

		// y (back)
		if (struts[1])
		reflect(x = reflect[1] ? [1, -1] : false, y = false)
		translate([pos[0], 0])
		rotate([0, 0, 90])
		children();
	}
}

module shape_booms(
		dim = BOOM_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		offset = 0,
	) {
	//pos_booms(offset = clamp_width + TOLERANCE_CLOSE + (BOOM_LENGTH_NAT - BOOM_LENGTH))
	pos_booms()
	translate([dim[0] / 2, 0])
	square([dim[0] + offset * 2, dim[1] + offset * 2], true);
}

module shape_frame_stock() {
	shape_booms();
	shape_struts();
}

module shape_struts(
		dim = STRUT_DIM,
		offset = 0,
		struts = [true, true],
	) {
	pos_struts(struts = struts)
	square([dim[0] + offset * 2, dim[1] + offset * 2], true);
}
