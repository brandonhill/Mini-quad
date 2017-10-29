
include <_conf.scad>;
include <_setup.scad>;
use <antenna mount.scad>;
use <camera mount.scad>;
use <canopy.scad>;

module shape_frame_clamps(
		boom_dim = BOOM_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		dim = FRAME_DIM,
		motor_angle = BOOM_ANGLE,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		top = false,
	) {

	r = top ?
		nut_dim[1] / 2 + TOLERANCE_FIT + screw_surround :
		screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround;

	smooth_acute(screw_surround) {
		intersection() {
			shape_frame(plate = true, top = top);

			reflect(y = false)
			hull()
			for (a = [0, 180])
			rotate([0, 0, motor_angle + a])
			translate([boom_dim[0], 0])
			circle(boom_dim[1] / 2 + TOLERANCE_FIT + clamp_width);
		}

		// surrounds
		pos_frame_screws(hull = true)
		circle(r);
	}
}

module shape_frame(
		batt_dim = BATT_DIM,
		batt_strap_dim = STRAP_HOLE_DIM,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		buzzer_pos = BUZZER_POS,
		cam_dim = CAM_HOUSING_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		dim = FRAME_DIM,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		plate_thickness = FRAME_PLATE_THICKNESS,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		plate = false,
		rx_dim = RX_DIM,
		rx_pos = RX_POS,
		top = false,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
	) {

	r = top ?
		nut_dim[1] / 2 + TOLERANCE_FIT + screw_surround :
		screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround;

	if (plate)
		difference() {
			hull()
			pos_frame_screws()
			circle(r);

			// battery strap notch
			if (!top)
				reflect(x = false)
				translate([0, batt_dim[1] / 2 + batt_strap_dim[1] / 2])
				square(batt_strap_dim, true);
		}

	if (top) {

		// cam mount
		*difference() {
			pos_frame_screws(show = [true, false]) {
				translate([0, -6])
				square([clamp_width * 2, 12], true);

				translate([0, -10])
				rotate([0, 0, boom_angle])
				translate([0, -3])
				square([clamp_width * 2, 6], true);
			}

			// cam cutout
			square([boom_dim[0], cam_dim[0] + TOLERANCE_FIT * 2], true);

			// remove back
			translate([-boom_dim[0] / 2, 0])
			square(boom_dim[0], true);
		}

		// antenna mount
		shape_ant_mount();

		// buzzer mount
		translate([0, plate_thickness / 2])
		translate(buzzer_pos)
		square([dim[0] / 2, plate_thickness], true);

		// cam mount
		shape_camera_mount();

		// rx mount
		translate([0, -(rx_dim[2] + plate_thickness) / 2])
		translate(rx_pos)
		square([dim[0] * 0.75, plate_thickness], true);

		// vtx mount
		translate([plate_thickness / 2 + vtx_dim[2] / 2, 0])
		translate(vtx_pos)
		square([plate_thickness, dim[0] / 2], true);
	}
}

module pos_frame_screws(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		dim = FRAME_DIM,
		hull = false,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		reflect = [true, true], // [x, y]
		show = [true, true], // [x, y]
	) {

	nut_rad = nut_dim[0] / 2 / cos(60);

	module pair() {
		reflect(x = false, y = show[1] ? [-1, 1] : false)
		translate([
			min(dim[0], dim[1]) / 2 / sin(boom_angle) // place at frame corner
			- (nut_rad + TOLERANCE_FIT + screw_surround) / sin(boom_angle)
			- nut_rad + TOLERANCE_FIT * sin(boom_angle)
			,
			-((boom_dim[1] + screw_dim[0]) / 2 + TOLERANCE_FIT)
			])
		children();
	}

	pos_booms(reflect = reflect) {
		if (hull) {
			hull()
			pair()
			children();
		} else {
			pair()
			children();
		}
	}
}

module fc_mount_post(
		h_post = FC_MOUNT_HEIGHT,
		nut_dim = FC_MOUNT_NUT_DIM,
		pitch = FC_MOUNT_THREAD_PITCH,
		r = FC_HOLE_RAD,
		thickness = FC_BOARD_THICKNESS,
		tolerance = TOLERANCE_CLEAR,
	) {

	color(PRINT_COLOUR != undef ? PRINT_COLOUR : undef) {
		cylinder(h = h_post, r = r * 2);

		translate([0, 0, h_post]) {
			if (FINAL_RENDER) {
				metric_thread(diameter = r * 2, pitch = pitch, length = h_threads);
			} else {
				cylinder(h = thickness + nut_dim[2], r = r);
			}

			translate([0, 0, thickness])
			% nut(nut_dim);
		}
	}

	translate([0, 0, h_post + thickness])
	% nut(nut_dim);
}

module pos_fc_holes(
		hole_spacing = FC_HOLE_SPACING,
	) {
	reflect()
	translate(hole_spacing / 2)
	children();
}

module fc_mount_posts() {
	pos_fc_holes()
	fc_mount_post();
}

module frame(
		ant_nut_dim = SMA_NUT_DIM,
		batt_dim = BATT_DIM,
		batt_strap_dim = STRAP_HOLE_DIM,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		cam_screw_dim = CAM_SCREW_DIM,
		clamp_thickness_bot = FRAME_CLAMP_THICKNESS_BOT,
		clamp_thickness_top = FRAME_CLAMP_THICKNESS_TOP,
		clamp_width = FRAME_CLAMP_WIDTH,
		dim = FRAME_DIM,
		motor_angle = BOOM_ANGLE,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		top = false,
		plate_thickness = FRAME_PLATE_THICKNESS,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_length = FRAME_CLAMP_SCREW_LENGTH,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
	) {

	clamp_thickness = top ? clamp_thickness_top : clamp_thickness_bot;

	h = clamp_thickness_bot * 2 + (clamp_thickness - clamp_thickness_bot);

	// fc mounts
	if (top)
	scale([1, 1, -1])
	fc_mount_posts();

	difference() {
		color(PRINT_COLOUR != undef ? PRINT_COLOUR : undef)
		union() {

			// boom clamps
			linear_extrude(h, convexity = 2)
			shape_frame_clamps(top = top);

			linear_extrude(h, convexity = 2)
			smooth_acute(1)
			shape_frame(top = top);

			// need to get skinny stuff, so no smoothing here
			linear_extrude(h, convexity = 2)
			shape_frame(top = top);

			// ant mount surround
			if (top)
			intersection() {
				scale([1, 1, -1])
				linear_extrude(20, convexity = 2)
				shape_frame(top = top);

				pos_ant(z = 0)
				cylinder(h = clamp_thickness * 2, r = ant_nut_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround, center = true);
			}

			// screw surrounds
			pos_frame_screws(hull = true)
			screw_surround(dim = screw_dim, h = h, tolerance = TOLERANCE_CLEAR, walls = screw_surround);

			if (!top) {
				// plate
				difference() {
					linear_extrude(h, convexity = 2)
					difference() {
						smooth_acute(1)
						shape_frame(plate = true);

						smooth(2)
						difference() {
							offset(r = -clamp_width * 1.5)
							shape_frame(plate = true);

							// boom clamps
							shape_frame_clamps(top = top);
						}
					}

					// battery strap notch bevel
					reflect(x = false)
					translate([0, batt_dim[1] / 2 + 1, clamp_thickness_bot * 2])
					rotate([45, 0])
					cube([batt_strap_dim[0], 4, 4], true);
				}
			}
		}

		// ant hole
		if (top)
		pos_ant(z = 0)
		cylinder(h = clamp_thickness * 2, r = ant_nut_dim[0] / 2 + TOLERANCE_CLEAR, center = true);

		// booms
		translate([0, 0, clamp_thickness])
		diff_booms(offset = TOLERANCE_FIT);

		// cam screw holes
		pos_camera(z = false)
		translate([0, 0, h / 2])
		rotate([90, 0])
		cylinder(h = boom_dim[0], r = cam_screw_dim[0] / 2 + TOLERANCE_CLEAR, center = true);

		// canopy clip notches
		translate([0, 0, h])
		scale([1, 1, -1]) {
			canopy_clips_back(offset = TOLERANCE_FIT);
			canopy_clips_front(offset = TOLERANCE_FIT);
		}

		// nut/screw holes
		pos_frame_screws() {
			scale([1, 1, -1])
			screw_diff(dim = screw_dim, h = screw_length, mock = !top, tolerance = TOLERANCE_CLOSE);

			if (top)
			nut_diff(nut_dim, mock = true, tolerance = TOLERANCE_FIT);
		}
	}

	// dim check
*
	#
	translate([0, 0, -20])
	cube([dim[0], dim[1], 1], true);
}
