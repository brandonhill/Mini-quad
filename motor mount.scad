
include <_conf.scad>;
use <_setup.scad>;
use <frame.scad>;

module pos_motor_clamp_screws(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		front = false,
		mount_rad = MOTOR_MOUNT_RAD,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		show_inner = true,
		show_outer = true,
		outset = true, // false will position at boom-strut intersection
		size = SIZE,
		strut_pos = STRUT_POS,
	) {

	// inner offset from motor center [x strut, y strut]
	strut_screw_pos_inner = [
		(size[0] / 2 - abs(strut_pos[0])) / cos(boom_angle) // motor centre to boom/strut intersection
		+ (outset ?
			((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_FIT) / cos(boom_angle) + // to edge of strut
			((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_FIT) / tan(90 - boom_angle) // clear boom
			:
			0
			),
		(size[1] / 2 - abs(strut_pos[1])) / cos(90 - boom_angle)
		+ (outset ?
			((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_FIT) / cos(90 - boom_angle) +
			((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_FIT) / tan(boom_angle)
			:
			0
			)
		];
	strut_screw_pos_y = (boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_FIT;

	pos_motor()
	rotate([0, 0, boom_angle]) {

		// outer, at edge of motor mount
		if (show_outer)
		reflect(x = false)
		translate([
			mount_rad - screw_dim[0] / 2 - screw_surround,
			strut_screw_pos_y])
		children();

		// inner
		if (show_inner) {

			// back strut
			if (!front)
			translate([
				-strut_screw_pos_inner[0],
				-strut_screw_pos_y
				])
			children();

			// side strut
			translate([
				-strut_screw_pos_inner[1],
				strut_screw_pos_y
				])
			children();
		}
	}
}

module shape_motor_mount_frame_screw_surrounds(
		front = false,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		show_inner = true,
		show_outer = true,
		top = false,
	) {

	r = top ?
			nut_dim[1] / 2 + TOLERANCE_FIT + screw_surround :
			screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround
			;

	// outer
	if (show_outer)
	intersection() {
		shape_motor();

		pos_motor_clamp_screws(front = front, show_inner = false, show_outer = show_outer)
		circle(r);
	}

	// inner
	if (show_inner)
	pos_motor_clamp_screws(front = front, show_inner = show_inner, show_outer = false)
	circle(r);
}

module shape_motor(
		a = MOTOR_OUTSET_ANGLE,
		boom_angle = BOOM_ANGLE,
		mount_rad = MOTOR_MOUNT_RAD,
		motor_screw_dim = MOTOR_SCREW_DIM,
		outset = MOTOR_MOUNT_OUTSET,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
	) {

	// mount area
	hull()
	pos_motor_screws()
	circle(motor_screw_dim[1] / 2 + TOLERANCE_CLOSE + screw_surround);

	// protection
	pos_motor()
	rotate([0, 0, boom_angle - a / 2])
	segment(a, mount_rad + outset);
}

module shape_motor_boom_clamp(
		boom_angle = BOOM_ANGLE,
		clamp_width = FRAME_CLAMP_WIDTH,
		top = false,
	) {

	intersection() {
		union() {
			shape_motor();
			hull()
			shape_motor_mount_frame_screw_surrounds(top = top);
		}

		offset(delta = clamp_width + TOLERANCE_FIT)
		shape_booms();
	}
}

module shape_motor_strut_clamp(
		boom_angle = BOOM_ANGLE,
		clamp_width = FRAME_CLAMP_WIDTH,
		front = false,
	) {

	intersection() {
		union() {
			shape_motor();

			pos_motor_clamp_screws(outset = false, show_outer = false)
			rotate([0, 0, -boom_angle])
			square(20, true);
		}

		offset(delta = clamp_width + TOLERANCE_FIT)
		shape_struts(all = !front);
	}
}

module shape_clamps(
		front = false,
	) {
	shape_motor_boom_clamp();
	shape_motor_strut_clamp(front = front);
}

module shape_motor_mount(
		boom_angle = BOOM_ANGLE,
		clamp_width = FRAME_CLAMP_WIDTH,
		front = false,
		motor_screw_dim = MOTOR_SCREW_DIM,
		mount_rad = MOTOR_MOUNT_RAD,
		clamp_screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		top = true,
	) {

	union() {
		if (top) {
			hull() {
				shape_motor();
				offset(r = -clamp_width * 2)
				shape_clamps(front = front);
			}
		} else {
			shape_motor_boom_clamp(top = top);
			shape_motor_strut_clamp(front = front);
		}

		hull()
		shape_motor_mount_frame_screw_surrounds(front = front, show_outer = false, top = top);

		hull()
		shape_motor_mount_frame_screw_surrounds(front = front, show_inner = false, top = top);
	}
}

module motor_mount(
		boom_angle = BOOM_ANGLE,
		boom_thickness = BOOM_THICKNESS,
		clamp_length = FRAME_CLAMP_LENGTH,
		clamp_thickness_bot = FRAME_CLAMP_THICKNESS_BOT,
		clamp_thickness_top = FRAME_CLAMP_THICKNESS_TOP,
		clearance_dim = MOTOR_CLEARANCE_DIM,
		front = false,
		height = BOOM_HEIGHT,
		landing_gear_height = LANDING_GEAR_HEIGHT,
		mount_outset = MOTOR_MOUNT_OUTSET,
		mount_rad = MOTOR_MOUNT_RAD,
		motor_screw_dim = MOTOR_SCREW_DIM,
		min_thickness = 0,
		mount_thickness = MOTOR_MOUNT_THICKNESS,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		clamp_screw_dim = FRAME_CLAMP_SCREW_DIM,
		clamp_screw_length = FRAME_CLAMP_SCREW_LENGTH,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		top = true,
	) {

	clamp_thickness = top ? clamp_thickness_top : clamp_thickness_bot;

	difference() {
		color(PRINT_COLOUR != undef ? PRINT_COLOUR : undef)
		union() {

			// motor mount
			if (top)
			linear_extrude(mount_thickness, convexity = 2)
			smooth_acute(4) {
				shape_motor_mount(front = front);
				shape_motor_mount(front = front, top = false);
			}

			// frame clamp
			linear_extrude(clamp_thickness_bot * 2 + (clamp_thickness - clamp_thickness_bot), convexity = 2)
			smooth_acute(1)
			shape_motor_mount(front = front, top = false);
		}

		// boom/strut channels
		translate([0, 0, clamp_thickness])
		diff_frame_stock(all = !front, offset = TOLERANCE_FIT);

		// clamp nut/screw holes
		pos_motor_clamp_screws(front = front) {
			scale([1, 1, -1])
			screw_diff(dim = clamp_screw_dim, h = clamp_screw_length, mock = !top, tolerance = TOLERANCE_CLOSE);

			if (top)
			nut_diff(nut_dim, mock = true, tolerance = TOLERANCE_FIT);
		}

		// motor
		if (top) {
			// shaft clearance
//			#
			translate([0, 0, -0.1])
			pos_motor()
			cylinder(h = clearance_dim[1], r = clearance_dim[0] / 2);

			// screw holes
			linear_extrude((top ? mount_thickness : clamp_thickness) * 5, center = true, convexity = 2)
			pos_motor_screws()
			circle(motor_screw_dim[0] / 2 + TOLERANCE_CLOSE);

			// screw head clearance
			translate([0, 0, mount_thickness])
			linear_extrude(clamp_thickness * 3)
			pos_motor_screws()
			circle(motor_screw_dim[1] / 2 + TOLERANCE_CLOSE);
		}
	}
}
