
include <_setup.scad>;
use <frame.scad>;

module pos_canopy_clips_back(
		boom_angle = BOOM_ANGLE,
		frame_dim = FRAME_DIM,
	) {

	// back
	reflect(x = false)
	translate(-frame_dim / 2)
	rotate([0, 0, boom_angle]) {

		// all manual right now :( TODO: automate
		translate([0, 12])
		rotate([0, 0, -6])
		translate([4.5, 0])

		children();
	}
}

module pos_canopy_clips_front(
		boom_angle = BOOM_ANGLE,
		frame_dim = FRAME_DIM,
	) {

	// front
	reflect(x = false)
	translate(frame_dim / 2)
	rotate([0, 0, boom_angle]) {

		// manual
		rotate([0, 0, -20])
		translate([-2.25, -8])

		scale([-1, 1])
		children();
	}
}

module canopy_clips_back(
		offset = 0,
		width = CANOPY_CLIP_WIDTH_BACK,
	) {
	pos_canopy_clips_back()
	canopy_clip(
		offset = offset,
		width = width);
}

module canopy_clips_front(
		offset = 0,
		width = CANOPY_CLIP_WIDTH_FRONT,
	) {
	pos_canopy_clips_front()
	canopy_clip(
		front = true,
		offset = offset,
		width = width);
}

module canopy_clip(
		width,
		offset = 0,
	) {
	rotate([90, 0])
	linear_extrude(width + offset * 2, center = true)
	offset(r = offset)
	shape_canopy_clip();
}

module shape_canopy_clip(
		front = false,
		thickness = CANOPY_THICKNESS,
	) {
	polygon([
		[front ? -thickness * 2 : 0, 0],
		[0, thickness * 2],
		[thickness * 2, 0],
	]);
}

module canopy_solid(
		ant_mount_thickness = ANT_MOUNT_THICKNESS,
		ant_nut_dim = SMA_NUT_DIM,
		ant_pos = ANT_POS,
		cam_dim = CAM_DIM,
		cam_pos = CAM_POS,
		clamp_thickness_bot = FRAME_CLAMP_THICKNESS_BOT,
		clamp_thickness_top = FRAME_CLAMP_THICKNESS_TOP,
		clamp_width = FRAME_CLAMP_WIDTH,
		fc_dim = FC_DIM,
		fc_pos = FC_POS,
		frame_dim = FRAME_DIM,
		rounding = CANOPY_ROUNDING,
		offset = 0,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = CANOPY_THICKNESS,
	) {

	$fn = 8;

	h_frame_top = clamp_thickness_bot * 2 + (clamp_thickness_top - clamp_thickness_bot);
	r = rounding + offset;

	hull()
	reflect(x = false) {

		// ant mount
		pos_ant()
		translate([0, 0, -offset])
		cylinder(
			h = ant_mount_thickness + TOLERANCE_CLEAR + thickness + offset * 2,
			r = ant_nut_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround + TOLERANCE_CLEAR + thickness + offset);

		// camera
		pos_camera() {
			reflect(x = 0, y = 0, z = true) {

				// lens front
				translate([cam_dim[2] / 2 - rounding, cam_dim[0] / 2 - rounding, cam_dim[1] / 2 - rounding])
				sphere(r);

				// housing
				translate([0, cam_dim[0] / 2, cam_dim[1] / 2])
				sphere(r);
			}


			// mount
			translate([0, cam_dim[0] / 2 + clamp_width * 2])
			sphere(r);
		}

		translate(fc_pos) {

			// ease angle at back (for printing)
			translate([
				ant_pos[0] + rounding * 2,
				0,
				fc_dim[2] / 2])
			sphere(r);

			// fc
			reflect(y = 0)
			translate([0, -rounding / 2])
			translate(fc_dim / 2)
			sphere(r);

			// lens front at top (for printing)
			translate([
				cam_pos[0] - rounding,
				cam_dim[0] / 2 - rounding,
				fc_dim[2] / 2
				])
			sphere(r);
		}

		// frame (top)
		translate([0, 0, FRAME_HEIGHT])
		scale([1, 1, -1])
		translate([0, 0, -offset])
		linear_extrude(h_frame_top + offset * 2, convexity = 2)
		offset(r = TOLERANCE_CLEAR + thickness + offset) {
			shape_frame(top = true);
			shape_frame_clamps(top = true);
		}

		// bottom
		translate([0, 0, clamp_thickness_bot * 2 - offset])
		linear_extrude(10 + offset * 2)
		offset(r = offset)
		hull()
		shape_frame_clamps();
	}
}

module canopy(
		ant_nut_dim = SMA_NUT_DIM,
		boom_dim = BOOM_DIM,
		cam_cutout_r = CANOPY_CAM_CUTOUT_RAD,
		cam_dim = CAM_DIM,
		clamp_thickness_bot = FRAME_CLAMP_THICKNESS_BOT,
		clamp_thickness_top = FRAME_CLAMP_THICKNESS_TOP,
		dim = FRAME_DIM,
		frame_height = FRAME_HEIGHT,
		motor_mount_thickness = MOTOR_MOUNT_THICKNESS,
		rounding = CANOPY_ROUNDING,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = CANOPY_THICKNESS,
	) {

	h_frame_bot = clamp_thickness_bot * 2;
	h_frame_top = clamp_thickness_bot * 2 + (clamp_thickness_top - clamp_thickness_bot);

	difference() {
		union() {
			difference() {
				canopy_solid();
				canopy_solid(offset = -thickness);
			}
		}

		// camera cutout
		pos_camera()
		translate([
			cam_dim[2] / 2 + rounding / 2,
			0,
			-cam_dim[1]  / 2])
		capsule(h = cam_dim[1], r = cam_cutout_r);

		// antenna cutout
		hull()
		for (z = [0, frame_height])
		translate([-dim[0] / 2, 0, z])
		rotate([0, 90])
		cylinder(h = dim[0], r = ant_nut_dim[1] / 2 + TOLERANCE_CLEAR * 2, center = true);

		// back cutout
		translate([
			-dim[0] - dim[0] / 2 + boom_dim[1], // manual - TODO: improve
			0, -h_frame_top])
		cube([dim[0] * 2, dim[1] * 2, frame_height * 2], true);

		// boom cutouts
		translate([0, 0, clamp_thickness_bot])
		pos_booms()
		translate([boom_dim[0] / 2, 0])
		for (z = [0, 1])
		hull() {
			translate([0, 0, boom_dim[2] - 1 + TOLERANCE_FIT - clamp_thickness_bot * z])
			cube([boom_dim[0], boom_dim[1] + TOLERANCE_FIT * 2, 2], true);

			cube([boom_dim[0], (boom_dim[1] + TOLERANCE_FIT * 2) + boom_dim[2] * z, 2], true);
		}

		// bottom cutout
		linear_extrude(h_frame_bot * 2)
		offset(r = -(thickness + TOLERANCE_CLEAR))
		projection(cut = true)
		translate([0, 0, -h_frame_bot - 1])
		canopy_solid();
	}

	// clips
	translate([0, 0, frame_height - h_frame_top]) {
		canopy_clips_back();

		canopy_clips_front();
	}

	// front clip attachment
	intersection() {
		canopy_solid();

		translate([0, 0, frame_height - h_frame_top])
		pos_canopy_clips_front()
		hull() {
			translate([-5, 5, h_frame_top / 2])
			cube([10, 15, h_frame_top], true);

			translate([-10, 10, frame_height])
			cube([10, 15, h_frame_top], true);
		}
	}
}
