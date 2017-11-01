
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
		batt_strap_dim = BATT_STRAP_DIM,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		braces = true,
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

		// antenna mount
		shape_ant_mount();

		// cam mount
		shape_camera_mount();

	} else if (braces) {

		// vtx mount
		translate([vtx_pos[0] + vtx_dim[2] / 2 + dim[0] / 4, 0])
		rotate([0, 0, 90])
		t([dim[1] / 2, dim[0] / 4], plate_thickness, center = false);
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
		col,
		h_post = FC_MOUNT_HEIGHT,
		screw_dim = FC_MOUNT_SCREW_DIM,
		pitch = FC_MOUNT_THREAD_PITCH,
		thickness = FC_BOARD_THICKNESS,
		tolerance = TOLERANCE_CLEAR,
	) {

	color(col != undef ? col : undef)
	difference() {
		cylinder(h = h_post, r = screw_dim[0]);
		thread_iso_metric(screw_dim[0], h_post + 0.1, pitch, center = false, internal = true);
	}

	translate([0, 0, h_post + thickness])
	% screw(screw_dim, 5);
}

module pos_fc_holes(
		hole_spacing = FC_HOLE_SPACING,
	) {
	transpose(hole_spacing / 2)
	children();
}

module fc_mount_posts(col) {
	pos_fc_holes()
	fc_mount_post(col);
}

module frame(
		ant_nut_dim = SMA_NUT_DIM,
		batt_dim = BATT_DIM,
		batt_strap_dim = BATT_STRAP_DIM,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		buzzer_dim = BUZZER_DIM,
		buzzer_pos = BUZZER_POS,
		cam_screw_dim = CAM_SCREW_DIM,
		clamp_thickness_bot = FRAME_CLAMP_THICKNESS_BOT,
		clamp_thickness_top = FRAME_CLAMP_THICKNESS_TOP,
		clamp_width = FRAME_CLAMP_WIDTH,
		col,
		dim = FRAME_DIM,
		frame_height = FRAME_HEIGHT,
		motor_angle = BOOM_ANGLE,
		mount_dim = COMPONENT_MOUNT_DIM,
		mount_thickness = COMPONENT_MOUNT_THICKNESS,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		top = false,
		pdb_dim = PDB_DIM,
		pdb_rot = PDB_ROT,
		plate_thickness = FRAME_PLATE_THICKNESS,
		rx_dim = RX_DIM,
		rx_pos = RX_POS,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_length = FRAME_CLAMP_SCREW_LENGTH,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		vtx_dim = VTX_DIM,
		vtx_pos = VTX_POS,
		zip_tie_dim = ZIP_TIE_DIM,
	) {

	clamp_thickness = top ? clamp_thickness_top : clamp_thickness_bot;

	h = clamp_thickness_bot * 2 + (clamp_thickness - clamp_thickness_bot);

	// fc mounts
	if (top)
	scale([1, 1, -1])
	fc_mount_posts(col);

	difference() {
		color(col != undef ? col : undef)
		union() {

			// boom clamps
			linear_extrude(h, convexity = 2)
			shape_frame_clamps(top = top);

			linear_extrude(h, convexity = 2)
			smooth_acute(1)
			shape_frame(braces = false, top = top);

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

			if (top) {

				// buzzer mount
				l = buzzer_pos[1] - buzzer_dim[0] * 0.125;
				*translate([0, 0, 0])
				translate([buzzer_pos[0], 0, h - plate_thickness])
				linear_extrude(plate_thickness)
				difference() {
					polygon([
						[0, 0],
						[l, l],
						[-l, l],
					]);
					translate([0, buzzer_pos[1]])
					circle(buzzer_dim[0] / 2 + TOLERANCE_FIT);
				}
			} else {

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

		if (top) {

			// ant hole
			pos_ant(z = 0)
			cylinder(h = clamp_thickness * 2, r = ant_nut_dim[0] / 2 + TOLERANCE_CLEAR, center = true);

			// batt wire zip tie hole
			// manual! TODO: automate
			translate([-dim[0] / 2 + 5, dim[1] / 2 - 5, h / 2])
			rotate([0, 0, boom_angle - 12])
			translate([-10, -3])
			cube([zip_tie_dim[0] + TOLERANCE_FIT * 2, zip_tie_dim[1] + TOLERANCE_FIT * 2, h * 2], true);

			// pdb cutout
			translate([0, 0, pdb_dim[2] / 2])
			rotate(pdb_rot)
			cube([
				pdb_dim[0] + TOLERANCE_FIT * 2,
				pdb_dim[1] + TOLERANCE_FIT * 2,
				pdb_dim[2] + TOLERANCE_FIT,
				], true);
		}

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

	color(col != undef ? col : undef)
	if (top) {

		// pdb retention tabs
		pos_booms()
		translate([pdb_dim[0] / 2 + TOLERANCE_FIT, 0, TOLERANCE_FIT])
		rotate([-90, 0])
		pie(135, clamp_width / 2, boom_dim[1] + (TOLERANCE_FIT + clamp_width) * 2, center = true);

	} else {

		difference() {
			union() {
				// buzzer mount
				translate([0, buzzer_pos[1] + 2.5 - 1, h])
				rotate([0, -90, 90])
				beam_u([buzzer_dim[0] * 2/3 + batt_strap_dim[1] + TOLERANCE_CLEAR, mount_dim[1], batt_strap_dim[0] + (TOLERANCE_CLEAR + mount_thickness) * 2], mount_thickness, center = false, convexity = 2);

				// rx mount
				translate([0, rx_pos[1] - mount_dim[1] - rx_dim[2] / 2, h])
				rotate([0, -90, -90])
				beam_u([
					rx_dim[1] * 2/3 + batt_strap_dim[1] + TOLERANCE_CLEAR, mount_dim[1],
					batt_strap_dim[0] + (TOLERANCE_CLEAR + mount_thickness) * 2], mount_thickness, center = false, convexity = 2);
			}

			// battery strap cutout
			translate([0, 0, h])
			rotate([90, 0])
			linear_extrude(dim[1], center = true)
			hull()
			reflect()
			translate([(batt_strap_dim[0] - batt_strap_dim[1]) / 2 + TOLERANCE_CLEAR, batt_strap_dim[1] / 2])
			circle(batt_strap_dim[1] / 2);

			// buzzer cutout
			translate([0, 0, h])
			rotate([0, -90, 90])
			linear_extrude(dim[1] / 2, convexity = 2)
			translate([buzzer_pos[2] - h, 0])
			circle(buzzer_dim[0] / 2 + TOLERANCE_FIT);
		}

		// vtx mount
		translate([vtx_pos[0] + vtx_dim[2] / 2 + mount_dim[1], 0])
		rotate([0, -90, 0])
		beam_t([vtx_dim[1] * 2/3, mount_dim[0], mount_dim[1]], mount_thickness, center = false);
	}

	// dim check
*
	#
	translate([0, 0, -20])
	cube([dim[0], dim[1], 1], true);
}
