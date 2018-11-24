
include <_setup.scad>;
use <antenna mount.scad>;
use <camera mount.scad>;
use <canopy.scad>;

module diff_frame_screws(
		clamp_screw_dim = FRAME_CLAMP_SCREW_DIM,
		clamp_screw_length = FRAME_CLAMP_SCREW_LENGTH,
	) {
	pos_frame_screws()
	mirror([0, 0, 1])
	screw_diff(dim = clamp_screw_dim, h = clamp_screw_length, tolerance = TOLERANCE_CLOSE);
}

module fc_mount_post(
		h = STACK_MOUNT_HEIGHT,
		hole = true,
		screw_dim = FC_MOUNT_SCREW_DIM,
		pitch = FC_MOUNT_THREAD_PITCH,
		surround = FC_MOUNT_SCREW_SURROUND,
		thickness = FC_BOARD_THICKNESS,
		tolerance = TOLERANCE_CLEAR,
	) {

	r = screw_dim[0] / 2 + tolerance + surround;
	smc_clearance = 1.5;

	difference() {
		union() {
			cylinder(h = h - smc_clearance, r = r);
			translate([0, 0, h - smc_clearance])
			cylinder(h = smc_clearance, r1 = r, r = screw_dim[0] / 2 + tolerance + PRINT_NOZZLE_DIA / 2);

			hull() {
				cylinder(h = h - smc_clearance, r = r);
				translate([0, 0, -0.1]) {
					cylinder(h = 0.1, r = r);
					translate([h - smc_clearance, 0])
					cylinder(h = 0.1, r = r);
				}
			}
		}

		if (hole)
		translate([0, 0, -0.1])
		//thread_iso_metric(screw_dim[0], h + 0.2, pitch, center = false, internal = true, tolerance = tolerance);
		cylinder(h = h + 0.2, r = screw_dim[0] / 2);
	}

	*translate([0, 0, h + thickness])
	% screw(screw_dim, 5);
}

module fc_mount_posts(
		boom_angle = BOOM_ANGLE,
		holes = true,
		stack_hole_spacing = FC_HOLE_SPACING,
	) {
	reflect()
	translate(stack_hole_spacing / 2)
	rotate([0, 0, 180 + boom_angle])
	fc_mount_post(hole = holes);
}

module frame_bot(
		batt_dim = BATT_DIM,
		batt_mount_width = BATT_MOUNT_WIDTH,
		batt_strap_dim = BATT_STRAP_DIM,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
	) {

	battery_strap_notch = batt_strap_dim[1] / 3;
	h = clamp_thickness + clamp_depth;

	module shape() {

		module shape_plate() {
			difference() {
				union() {
					// boom clamps
					hull()
					shape_frame_clamps(top = false);

					// rx ant zip tie mounts
					pos_rx_ant_mount_holes()
					square([RX_ANT_MOUNT_DIM[0], RX_ANT_MOUNT_DIM[1] * 2], true);
				}

				// battery strap notches
				reflect(x = false) {
					translate([0, batt_mount_width / 2 + 10])
					square([batt_strap_dim[0] - battery_strap_notch, 20], true);

					translate([0, batt_mount_width / 2 + battery_strap_notch / 2])
					square([batt_strap_dim[0], battery_strap_notch], true);
				}

				// rx ant zip tie mount face
				pos_rx_ant_mount_holes()
				translate([0, RX_ANT_MOUNT_DIM[1]])
				square(RX_ANT_MOUNT_DIM, true);
			}
		}

		difference() {
			smooth(1)
			shape_plate();

			// interior cutouts
			smooth(2)
			difference() {
				offset(r = -clamp_thickness)
				shape_plate();

				shape_frame_clamps(top = false);
			}

			// rx ant zip tie holes
			pos_rx_ant_mount_holes()
			square([ZIP_TIE_DIM[0] + TOLERANCE_CLEAR * 2, ZIP_TIE_DIM[1] + TOLERANCE_CLEAR * 2], true);
		}

		// vtx mount
		*shape_vtx_mount();
	}

	difference() {
		linear_extrude(h, convexity = 2)
		shape(rx_ant_mount_closed = false);

		// battery strap bevel
		reflect(x = false)
		translate([0, (batt_mount_width + battery_strap_notch) / 2, h * 1.5])
		rotate([0, 90, 180])
		linear_extrude(batt_strap_dim[0], center = true)
		polygon([
			[0, 0],
			[0, h],
			[h, 0],
		]);

		// booms
		diff_booms(offset = TOLERANCE_CLOSE);

		// decrease rx ant mount height
		pos_rx_ant_mount_holes()
		translate([0, RX_ANT_MOUNT_DIM[1] / 2, h * 1.5 - ZIP_TIE_DIM[1] * 2])
		cube([
			ZIP_TIE_DIM[0] + TOLERANCE_CLEAR * 2,
			RX_ANT_MOUNT_DIM[1],
			h], true);

		// screw holes
		diff_frame_screws();
	}
}

module frame_top(
		ant_mount_surround = ANT_MOUNT_SURROUND,
		ant_mount_thickness = ANT_MOUNT_THICKNESS,
		ant_nut_dim = SMA_NUT_DIM,
		ant_pos = ANT_POS,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		buzzer_dim = BUZZER_DIM,
		buzzer_pos = BUZZER_POS,
		cam_dim = CAM_DIM,
		cam_pos = CAM_POS,
		cam_screw_dim = CAM_SCREW_DIM,
		cam_screw_surround = CAM_SCREW_SURROUND,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_nut_dim = FRAME_CLAMP_NUT_DIM,
		clamp_screw_dim = FRAME_CLAMP_SCREW_DIM,
		clamp_screw_length = FRAME_CLAMP_SCREW_LENGTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		clamp_width = FRAME_CLAMP_WIDTH,
		mount_thickness = COMPONENT_MOUNT_THICKNESS,
		rx_dim = RX_DIM,
		smoothing = 0.5,
		stack_hole_spacing = FC_HOLE_SPACING,
		stack_hole_rad = FC_HOLE_RAD,
		surround = FRAME_CLAMP_SCREW_SURROUND,
		zip_tie_dim = ZIP_TIE_DIM,
	) {

	h = clamp_thickness + clamp_depth;
	z = clamp_thickness + boom_dim[2] - clamp_depth;

	module shape_buzzer_mount() {
		module shape() {
			difference() {
				translate([0, buzzer_pos[1] * 0.9 - (buzzer_dim[0] + 50) / 2, 0])
				square(50, center = true);
				pos_buzzer(z = false)
				circle(buzzer_dim[0] / 2); // no tolerance here for a snug fit
			}
		}
		intersection() {
			difference() {
				shape();
				offset(delta = -mount_thickness)
				shape();
			}
			translate([buzzer_pos[0], buzzer_pos[1]])
			circle(buzzer_dim[0] / 2 + abs(buzzer_pos[1]));
		}
	}

	module shape_rx_mount() {
		translate([0, -(rx_dim[2] + mount_thickness) / 2])
		pos_rx(rot = [], z = false)
		square([rx_dim[0] + clamp_width * 2, mount_thickness], true);
	}

	difference() {
		union() {
			translate([0, 0, z])
			intersection() {
				linear_extrude(h, convexity = 3)
				difference() {
					union() {
						smooth_acute(smoothing) {
							shape_ant_mount_xy();
							shape_buzzer_mount();
							shape_camera_mount();
							shape_frame_clamps(top = true);
							shape_rx_mount();
							shape_vtx_mount(holes = false);
						}

						// restore required detail lost by smoothing:
						shape_buzzer_mount();
						shape_camera_mount();
						shape_rx_mount();
						shape_vtx_mount();
					}

					// battery wire zip tie hole
					mirror([1, 0])
					pos_frame_screws(reflect = [false, false])
					translate([-surround / 2, -(clamp_nut_dim[1] + surround * 1.5)])
					rotate([0, 0, 90])
					square([zip_tie_dim[0] + TOLERANCE_CLEAR * 2, zip_tie_dim[1] + TOLERANCE_CLEAR * 2], true);
				}

				// bevel camera mount front
				translate([-SIZE_DIA / 2 + cam_pos[0] + cam_screw_dim[0] / 2 + TOLERANCE_CLOSE + cam_screw_surround, 0, h / 2])
				rounded_cube([SIZE_DIA, SIZE_DIA, h], h / 2, edges = true, $fn = 8);
			}

			// VTx ant mount
			ant_mount(smoothing = smoothing);

			// stack mount posts
			translate([0, 0, z + h])
			fc_mount_posts();

			// nut surrounds
			difference() {
				pos_frame_nuts()
				cylinder(h = clamp_nut_dim[2],
					r1 = clamp_nut_dim[1] / 2 + TOLERANCE_CLOSE + surround,
					r2 = clamp_nut_dim[1] / 2 + TOLERANCE_CLOSE + PRINT_NOZZLE_DIA * 2);

				translate([0, 0, z + h])
				fc_mount_posts(holes = false);
			}
		}

		// booms
		diff_booms(offset = TOLERANCE_CLOSE);

		// camera mount holes
		pos_camera(rot = [0, 30])
		rotate([90, 0])
		cylinder_true(h = cam_dim[0] * 2, r = cam_screw_dim[0] / 2, $fn = 6);

		// canopy clip recesses
		canopy_clips(offset = TOLERANCE_FIT);

		// nut recesses
		pos_frame_nuts()
		nut_diff(clamp_nut_dim, tolerance = TOLERANCE_CLOSE);

		// screw holes
		diff_frame_screws();

		// stack mount hole through clearance (unthreaded)
		transpose(stack_hole_spacing / 2)
		translate([0, 0, z + clamp_depth])
		cylinder(h = clamp_thickness, r = stack_hole_rad);

		// vtx ant hole
		pos_ant() {
			cylinder_true(h = ant_mount_thickness * 3, r = ant_nut_dim[0] / 2 + TOLERANCE_CLEAR, center = true, $fn = 6);

			translate([0, 0, -ant_nut_dim[2] / 2])
			nut_diff(ant_nut_dim, tolerance = TOLERANCE_FIT);
		}

		// vtx mount slots
		translate([0, 0, z])
		linear_extrude(20, center = true, convexity = 2)
		shape_vtx_mount(diff = true);
	}
}

module pos_rx_ant_mount_holes() {
	reflect(x = false)
	translate(FRAME_DIM / 2)
	rotate([0, 0, BOOM_ANGLE])
	translate([
		-RX_ANT_MOUNT_DIM[0] / 2 + FRAME_CLAMP_SCREW_DIM[0] / 2 + TOLERANCE_CLOSE + FRAME_CLAMP_SCREW_SURROUND,
		BOOM_DIM[1] / 2 + FRAME_CLAMP_SCREW_DIM[0] + TOLERANCE_FIT + FRAME_CLAMP_WIDTH + ZIP_TIE_DIM[1] / 2])
	children();
}

module shape_boom_surrounds(
		boom_dim = BOOM_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		motor_angle = BOOM_ANGLE,
		r_outer,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
	) {

	r = r_outer + TOLERANCE_CLOSE + screw_surround;

	intersection() {

		// frame area
		hull()
		pos_frame_screws()
		circle(r);

		// boom surrounds
		pos_booms(outset = 0)
		translate([boom_dim[0] / 2, 0])
		square([boom_dim[0], boom_dim[1] + (TOLERANCE_CLOSE + clamp_width) * 2], true);
	}
}

module shape_frame_clamps(
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		top = false,
	) {

	r = (top ? nut_dim[1] : screw_dim[0]) / 2 + TOLERANCE_CLOSE + screw_surround;

	smooth_acute(screw_surround) {
		shape_boom_surrounds(r_outer = (top ? nut_dim[1] : screw_dim[0]) / 2);

		// screw surrounds
		pos_frame_screws(hull = true)
		circle(r);
	}
}

module shape_vtx_mount(
		clamp_width = FRAME_CLAMP_WIDTH,
		diff = false,
		holes = true,
		mount_thickness = COMPONENT_MOUNT_THICKNESS,
		vtx_dim = VTX_DIM,
		vtx_board_thickness = VTX_BOARD_THICKNESS,
		vtx_pos = VTX_POS,
	) {
	translate([vtx_pos[0] - vtx_board_thickness / 2, 0])
	difference() {
		if (!diff)
		translate([clamp_width / 2, 0])
		square([vtx_board_thickness + (TOLERANCE_FIT + mount_thickness) * 2 + clamp_width, vtx_dim[0] + clamp_width * 2], true);

		if (!diff)
		square([10, vtx_dim[0] - 0.25], true);

		if (holes || diff)
		square([vtx_board_thickness + TOLERANCE_FIT * 2, vtx_dim[0] + TOLERANCE_FIT * 2], true);
	}
}
