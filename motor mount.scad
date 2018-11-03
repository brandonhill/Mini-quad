
include <_setup.scad>;
use <frame.scad>;

module _X_motor_bumper(
		boom_dim = BOOM_DIM,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		frame_nut_dim = FRAME_CLAMP_NUT_DIM,
		frame_screw_dim = FRAME_CLAMP_SCREW_DIM,
		frame_screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		h = MOTOR_BUMPER_HEIGHT,
		mount_outset = MOTOR_MOUNT_OUTSET,
		mount_thickness = MOTOR_MOUNT_THICKNESS,
		ret = MOTOR_BUMPER_RET_THICKNESS,
		size = SIZE_DIA,
	) {

	a = 135;
	r_inner = frame_screw_dim[1] / 2 + TOLERANCE_CLOSE + ret;
	r_outer = frame_nut_dim[1] / 2 + frame_screw_surround + mount_outset;

	module shape() {
		difference() {
			smooth(1)
			hull() {
				translate([-ret - r_inner / 2, 0])
				circle(r_inner);

				intersection() {
					rotate([0, 0, 30])
					circle_true(r_outer, $fn = 6);

					rotate([0, 0, -a / 2])
					segment(a, r_outer * 2);
				}
			}

			// boom
			translate([-(boom_dim[0]) / 2 - frame_screw_dim[0] - ret - TOLERANCE_CLOSE, 0])
			offset(r = TOLERANCE_CLOSE)
			square([boom_dim[0], boom_dim[1]], true);

			// screw hole
			circle(frame_screw_dim[0] / 2 + TOLERANCE_CLOSE);
		}
	}

	pos_motor(i = -1)
	difference() {
		pos_motor()
		pos_motor_bumper(z = false)
		translate([0, 0, -frame_screw_dim[2]])
		linear_extrude(h, convexity = 2)
		shape();

		// upper (mount) clearance
		translate([0, 0, clamp_thickness + clamp_thickness + boom_dim[2]])
		mirror([0, 0, 1])
		linear_extrude(clamp_thickness + clamp_depth)
		offset(r = TOLERANCE_CLOSE)
		shape_motor_clamp();

		// lower (clamp) clearance
		translate([0, 0, 0])
		linear_extrude(clamp_thickness + clamp_depth)
		offset(r = TOLERANCE_CLOSE)
		shape_motor_clamp();

		scale([1, 1, -1])
		linear_extrude(frame_screw_dim[2] * 2)
		hull() {
			circle(frame_screw_dim[1]);

			pos_motor_clamp_screws(show_inner = false)
			translate([-frame_screw_dim[1] / 2, 0])
			circle(frame_screw_dim[1]);
		}
	}
}

module motor_clamp(
		depth = FRAME_CLAMP_DEPTH,
		r_outer = false,
		struts = [true, true], // [x, y]
		thickness = FRAME_CLAMP_THICKNESS,
	) {

	// base
	linear_extrude(thickness, convexity = 2)
	shape_motor_clamp(r_outer = r_outer, struts = struts);

	// edges
	translate([0, 0, thickness])
	linear_extrude(depth, convexity = 2)
	offset(delta = +0.5) offset(delta = -0.5) // remove tiny bits
	difference() {
		shape_motor_clamp(r_outer = r_outer, struts = struts);
		diff_shape_booms(offset = TOLERANCE_CLOSE);
		mirror([1, 0])
		diff_shape_struts(offset = TOLERANCE_CLOSE, struts = struts);
	}
}

module motor_mount(
		axle_clearance = MOTOR_CLEARANCE_DIM,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_nut_dim = FRAME_CLAMP_NUT_DIM,
		clamp_screw_dim = FRAME_CLAMP_SCREW_DIM,
		frame_clamp_thickness = FRAME_CLAMP_THICKNESS,
		frame_clamp_width = FRAME_CLAMP_WIDTH,
		frame_height = FRAME_HEIGHT,
		motor_rad = MOTOR_MOUNT_RAD,
		motor_screw_dim = MOTOR_SCREW_DIM,
		struts = [true, true],
		surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = MOTOR_MOUNT_THICKNESS,
	) {

	difference() {
		union () {

			translate([0, 0, frame_height + clamp_nut_dim[2] - thickness])
			linear_extrude(thickness, convexity = 10)
			difference() {
				smooth_acute(2) {
					hull() {

						// motor seat area
						pos_motor()
						intersection() {
							circle(motor_rad);

							hull()
							rotate([0, 0, boom_angle])
							for (x = [-1, 1])
							translate([10 * x, 0])
							rotate([0, 0, -boom_angle])
							pos_motor_screws()
							circle(motor_screw_dim[1] / 2 + TOLERANCE_CLOSE + 2);
						}

						// inner boom/strut joint
						pos_motor_clamp_screws(show_outer = false, struts = struts)
						circle(surround);
					}

					// clamp area
					shape_motor_clamp(r_outer = clamp_nut_dim[1] / 2, struts = struts);
				}

				// clamp screw holes
				pos_motor_clamp_screws(struts = struts)
				circle(clamp_screw_dim[0] / 2 + TOLERANCE_CLEAR);
			}

			// clamp
			translate([0, 0, frame_height + clamp_nut_dim[2]])
			mirror([0, 0, 1])
			motor_clamp(r_outer = clamp_nut_dim[1] / 2, struts = struts, thickness = frame_clamp_thickness + clamp_nut_dim[2]);
		}

		// nut recesses
		pos_motor_clamp_screws(struts = struts)
		translate([0, 0, clamp_nut_dim[2] * 1/3]) // partial outset to accommodate crushing of conical seat
		mirror([0, 0, 1])
		nut_diff(clamp_nut_dim, conical = true, mock = false, tolerance = TOLERANCE_CLOSE);

		// motor holes
		pos_motor() {

			// axle clearance
			mirror([0, 0, 1]) {
				translate([0, 0, -0.1])
				cylinder(h = axle_clearance[1] * 0.5 + 0.1, r = axle_clearance[0] / 2);
				translate([0, 0, axle_clearance[1] * 0.5])
				cylinder(h = axle_clearance[1] * 0.5 + 0.1, r1 = axle_clearance[0] / 2, r2 = axle_clearance[0] * 0.2);
			}

			// screw head clearance
			pos_motor_screws()
			translate([0, 0, -thickness])
			mirror([0, 0, 1])
			cylinder(h = thickness * 3, r = motor_screw_dim[1] / 2 + TOLERANCE_CLOSE);

			// screw holes
			pos_motor_screws()
			cylinder(h = thickness * 3, r = motor_screw_dim[0] / 2 + TOLERANCE_CLOSE, center = true);
		}

		offset(delta = frame_clamp_width + TOLERANCE_FIT)
		shape_booms();
	}
}

module motor_soft_mount(
		clearance_dim = MOTOR_CLEARANCE_DIM,
		mount_rad = MOTOR_MOUNT_RAD,
		motor_screw_dim = MOTOR_SCREW_DIM,
		thickness = MOTOR_SOFT_MOUNT_THICKNESS,
	) {

	linear_extrude(thickness)
	difference() {
		smooth_acute(2) {
			circle(mount_rad / 2);
			shape_motor_screw_area();
		}

		// axle clearance
		circle(clearance_dim[0] / 2 + TOLERANCE_CLEAR);

		// screw holes
		pos_motor_screws()
		circle(motor_screw_dim[0] / 2 + TOLERANCE_CLEAR);
	}
}

module pos_motor_bumper(
		boom_angle = BOOM_ANGLE,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		h = MOTOR_BUMPER_HEIGHT,
		mount_rad = MOTOR_MOUNT_RAD,
		mount_thickness = MOTOR_MOUNT_THICKNESS,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		i = 1,
		z = true,
	) {
	rotate([0, 0, boom_angle])
	translate([
		mount_rad - screw_surround - nut_dim[1] / 2,
		0,
		//z ? -clamp_thickness - h - (mount_thickness - clamp_thickness) : 0
		] * i)
	scale([1, 1, z ? -1 : 1])
	children();
}

module pos_motor_clamp_screws(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		mount_rad = MOTOR_MOUNT_RAD,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		show_inner = true,
		show_outer = true,
		outset = true, // false will position at boom-strut intersection
		size = SIZE,
		strut_dim = STRUT_DIM,
		strut_pos = STRUT_POS,
		struts = [true, true],
		z = true,
	) {

	// inner offset from motor center [x strut, y strut]
	strut_screw_pos_inner = [
		(size[0] / 2 - abs(strut_pos[0])) / cos(boom_angle) // motor centre to boom/strut intersection
		+ (outset ?
			((strut_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE) / cos(boom_angle) + // to edge of strut
			((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE) / tan(90 - boom_angle) // clear boom
			:
			0
			),
		(size[1] / 2 - abs(strut_pos[1])) / cos(90 - boom_angle)
		+ (outset ?
			((strut_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE) / cos(90 - boom_angle) +
			((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE) / tan(boom_angle)
			:
			0
			)
		];
	boom_screw_pos_y = (boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE;
	//strut_screw_pos_y = (strut_dim[1] + screw_dim[0]) / 2 + TOLERANCE_CLOSE;

	pos_motor(z = z)
	rotate([0, 0, boom_angle]) {

		// outer, at edge of motor mount
		if (show_outer)
		reflect(x = false, y = !MOTOR_CLAMP_SCREW_SINGLE_OUTER)
		translate([
			//mount_rad - screw_surround - nut_dim[1] / 2,
			mount_rad - screw_surround / 2 - nut_dim[1] / 2,
			MOTOR_CLAMP_SCREW_SINGLE_OUTER ? 0 : boom_screw_pos_y
			])
		children();

		// inner
		if (show_inner) {

			// back strut
			if (struts[1])
			translate([
				-strut_screw_pos_inner[0],
				-boom_screw_pos_y
				])
			children();

			// side strut
			translate([
				-strut_screw_pos_inner[1],
				boom_screw_pos_y
				])
			children();
		}
	}
}

module shape_motor(
		a = MOTOR_OUTSET_ANGLE,
		boom_angle = BOOM_ANGLE,
		mount_rad = MOTOR_MOUNT_RAD,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		outset = MOTOR_MOUNT_OUTSET,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
	) {

	// mount area
	intersection() {
		pos_motor()
		circle(mount_rad);

		hull()
		for (x = [0, mount_rad])
		rotate([0, 0, boom_angle])
		translate([x, 0])
		rotate([0, 0, -boom_angle])
		pos_motor()
		shape_motor_screw_area();
	}

	// nut surrounds
	hull()
	pos_motor_clamp_screws(show_inner = false, show_outer = true)
	circle(nut_dim[1] / 2 + TOLERANCE_CLOSE + screw_surround);

	// protection
	if (outset > 0)
	*pos_motor()
	rotate([0, 0, boom_angle - a / 2])
	segment(a, mount_rad + outset);
}

module shape_motor_boom_clamp(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		boom_strut_joint = BOOM_STRUT_JOINT,
		clamp_length = FRAME_CLAMP_LENGTH,
		clamp_width = FRAME_CLAMP_WIDTH,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		size = SIZE_DIA,
		struts = [true, true],
		surround = FRAME_CLAMP_SCREW_SURROUND,
	) {

	intersection() {
		rotate([0, 0, boom_angle])
		//translate([size / 2 + boom_strut_joint + boom_dim[1] - clamp_length, 0])
		translate([size / 4 + boom_strut_joint + boom_dim[1] - surround * 2 - screw_dim[0] - TOLERANCE_CLOSE * 2, 0])
		square(size / 2, true);

		offset(delta = TOLERANCE_CLOSE + clamp_width)
		shape_booms();
	}
}

module shape_motor_clamp(
		clamp_screw_dim = FRAME_CLAMP_SCREW_DIM,
		r_outer = false,
		struts = [true, true],
	) {

	difference() {
		smooth_acute(2) {
			shape_motor_boom_clamp(struts = struts);
			shape_motor_mount_frame_screw_surrounds(r_outer = r_outer != false ? r_outer : clamp_screw_dim[1] / 2, struts = struts);
			shape_motor_strut_clamp(struts = struts);
		}

		pos_motor_clamp_screws(struts = struts)
		circle(clamp_screw_dim[0] / 2 + TOLERANCE_CLEAR);
	}
}

module shape_motor_mount_frame_screw_surrounds(
		r_outer,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		show_inner = true,
		show_outer = true,
		struts = [true, true],
	) {

	r = r_outer + TOLERANCE_CLOSE + screw_surround;

	// outer
	if (show_outer)
	intersection()
	{
		shape_motor();

		hull()
		pos_motor_clamp_screws(show_inner = false, show_outer = true, struts = struts)
		circle(r);
	}

	// inner
	if (show_inner)
	hull()
	pos_motor_clamp_screws(show_inner = true, show_outer = false, struts = struts)
	circle(r);
}

module shape_motor_screw_area(
		motor_screw_dim = MOTOR_SCREW_DIM,
	) {

	pos_motor_screws()
	circle(motor_screw_dim[1] / 2 + TOLERANCE_CLOSE + 2);
}

module shape_motor_strut_clamp(
		boom_angle = BOOM_ANGLE,
		clamp_length = FRAME_CLAMP_LENGTH,
		clamp_width = FRAME_CLAMP_WIDTH,
		struts = [true, true],
	) {

	intersection() {
		union() {
			shape_motor();

			pos_motor_clamp_screws(outset = false, show_outer = false)
			rotate([0, 0, -boom_angle])
			square(clamp_length * 2, true); // arbitrary! TODO: restore CLAMP_LENGTH param
		}

		offset(delta = clamp_width + TOLERANCE_CLOSE)
		mirror([1, 0])
		shape_struts(struts = struts);
	}
}
