
include <_setup.scad>;
use <antenna mount.scad>;
use <frame.scad>;

module canopy(
		ant_nut_dim = SMA_NUT_DIM,
		ant_mount_surround = ANT_MOUNT_SURROUND,
		boom_dim = BOOM_DIM,
		cam_cutout_r = CANOPY_CAM_CUTOUT_RAD,
		cam_dim = CAM_DIM,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		clamp_width = FRAME_CLAMP_WIDTH,
		canopy_clip_width = CANOPY_CLIP_WIDTH,
		frame_height = FRAME_HEIGHT,
		motor_mount_thickness = MOTOR_MOUNT_THICKNESS,
		rounding = CANOPY_ROUNDING,
		//screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = CANOPY_THICKNESS,
	) {

	h_frame = clamp_thickness + clamp_depth;

	difference() {
		union() {
			difference() {
				canopy_solid(offset = TOLERANCE_CLEAR + thickness);
				canopy_solid(offset = TOLERANCE_CLEAR, inside = true);
			}
			*canopy_solid(offset = TOLERANCE_CLEAR + thickness);

			// clips
			intersection() {
				canopy_clips();
				canopy_solid(offset = TOLERANCE_CLEAR);
			}
		}

		// camera cutout
		pos_camera()
		translate([-CAM_PIVOT_OFFSET, 0])
		rotate([0, 90])
		linear_extrude(10, center = true)
		rounded_square([cam_dim[0], cam_dim[0]], 1);

		// VTx antenna cutout
		pos_ant(rot = [], z = false)
		rotate([0, -90])
		linear_extrude(20, center = true, convexity = 2)
		shape_ant_mount_yz(offset_xy = TOLERANCE_CLEAR, offset_z = TOLERANCE_CLEAR, full_width = false);

		// boom notches
		diff_booms(offset = TOLERANCE_CLEAR);

		// front boom clearance (angled portion)
		pos_booms(reflect = [false, true], z = false)
		hull()
		translate([boom_dim[0] / 2, 0]) {
			translate([0, 0, -1])
			cube([boom_dim[0], (boom_dim[1] + TOLERANCE_CLEAR * 2) + boom_dim[2], 2], true);
			translate([0, 0, boom_dim[2]])
			cube([boom_dim[0], (boom_dim[1] + TOLERANCE_CLEAR * 2), 2], true);
		}

		// cut excess
		translate([0, 0, -50]) {
			// front
			translate([(SIZE[0] + FRAME_DIM[0]) / 2, 0, clamp_thickness])
			cube([SIZE[0], SIZE[1], 100], true);

			// middle
			translate([0, 0, frame_height - h_frame])
			cube([FRAME_DIM[0] + clamp_width * 2, SIZE[1], 100], true);

			// back
			translate([-(SIZE[0] + FRAME_DIM[0]) / 2 - clamp_width + 0.1, 0, frame_height - clamp_thickness + TOLERANCE_CLEAR])
			cube([SIZE[0], SIZE[1], 100], true);

			// back taper
			translate([-(SIZE[0] + FRAME_DIM[0]) / 2, 0, frame_height - clamp_thickness + TOLERANCE_CLEAR])
			hull() {
				cube([SIZE[0], FRAME_DIM[1] + (clamp_width - canopy_clip_width) * 2, 100], true);

				translate([0, 0, clamp_thickness + TOLERANCE_CLEAR])
				cube([SIZE[0], SMA_NUT_DIM[1] + (TOLERANCE_CLEAR + ANT_MOUNT_SURROUND) * 2, 100], true);
			}
		}

		// vtx ant mount clearance
		*#pos_ant()
		translate([offset + TOLERANCE_CLEAR, 0, -offset - TOLERANCE_CLEAR])
		cylinder(
			h = ant_mount_thickness + offset * 2,
			r = ant_nut_dim[0] / 2 + ant_mount_surround + offset);
	}
}

module canopy_clip(
		width,
		depth = CANOPY_CLIP_DEPTH,
		offset = 0,
		rounded = false,
	) {
	rotate([90, 0])
	linear_extrude(width + offset * 2, center = true)
	smooth(rounded ? depth / 2 : 0)
	offset(delta = offset)
	shape_canopy_clip();
}

module canopy_clips(
		offset = 0,
		width = CANOPY_CLIP_WIDTH,
	) {
	canopy_clips_back(offset = offset, width = width);
	canopy_clips_front(offset = offset, width = width);
}

module canopy_clips_back(
		offset = 0,
		width = CANOPY_CLIP_WIDTH,
	) {
	pos_canopy_clips(front = false)
	canopy_clip(offset = offset, rounded = true, width = width);
}

module canopy_clips_front(
		offset = 0,
		width = CANOPY_CLIP_WIDTH,
	) {
	pos_canopy_clips(front = true)
	canopy_clip(offset = offset, width = width);
}

// this marks the interior of the canopy, excluding fit tolerance
module canopy_solid(
		ant_mount_surround = ANT_MOUNT_SURROUND,
		ant_mount_thickness = ANT_MOUNT_THICKNESS,
		ant_nut_dim = SMA_NUT_DIM,
		ant_pos = ANT_POS,
		cam_dim = CAM_DIM,
		cam_mount_thickness = CAM_MOUNT_THICKNESS,
		cam_pos = CAM_POS,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		fc_dim = FC_DIM,
		fc_pos = FC_POS,
		inside, // need this for VTx ant mount
		rounding = CANOPY_ROUNDING,
		offset = 0,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = CANOPY_THICKNESS,
	) {

	$fn_top = 8; // for printing

	h_frame = clamp_thickness + clamp_depth;
	r = rounding + offset;

	module corner(r = r, base = false) {
		sphere(r, $fn = base ? $fn_top : $fn);
	}

	hull()
	reflect(x = false) {

		// camera
		pos_camera() {
			reflect(x = 0, y = 0, z = true) {

				// lens front
				cam_protection = 0;
				translate([
					cam_dim[2] / 2 + cam_protection,
					cam_dim[0] / 2 + 2,
					cam_dim[0] / 2 + 2])
				corner(r = 1 + offset);

				// housing
				translate([0, cam_dim[0] / 2, (cam_dim[1] + rounding) / 2])
				corner();
			}

			// mount
			translate([0, cam_dim[0] / 2 + rounding])
			corner();
		}

		// top
		translate([0, 0, fc_pos[2] + fc_dim[2] / 2 - rounding / 2]) {

			// ease angle at back (for printing)
			translate([ant_pos[0] + rounding * 2, 0])
			corner(base = true);

			// fc
			reflect(y = 0)
			translate(-[rounding, rounding] / 2)
			translate([fc_dim[0], fc_dim[1]] / 2)
			corner(base = true);

			// ease angle at front (for printing)
			translate([fc_dim[0] / 2 + (cam_pos[0] - fc_dim[0] / 2) / 2, 0])
			corner(base = true);
		}

		difference() {
			union() {
				// frame (top)
				translate([0, 0, FRAME_HEIGHT - h_frame - offset])
				linear_extrude(h_frame + offset * 2, convexity = 2)
				offset(r = offset)
				projection()
				frame_top();

				// vtx ant mount
				*pos_ant()
				translate([0, 0, -offset - TOLERANCE_CLEAR])
				cylinder(
					h = ant_mount_thickness - (inside ? thickness : 0) + offset * 2,
					r = ant_nut_dim[0] / 2 + ant_mount_surround + TOLERANCE_CLEAR + thickness);
				ant_mount(offset_xy = offset);
			}

			// cut off back part of VTX ant mount
			translate([-50 + ant_pos[0] - ant_mount_thickness + (inside ? thickness : 0) - TOLERANCE_CLEAR, 0])
			cube(100, true);
		}

		// bottom
		translate([0, 0, -offset])
		linear_extrude(10 + offset * 2)
		offset(r = -thickness + offset)
		hull()
		shape_frame_clamps();
	}
}

module pos_canopy_clips(
		boom_dim = BOOM_DIM,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		depth = CANOPY_CLIP_DEPTH,
		frame_dim = FRAME_DIM,
		frame_nut_dim = FRAME_CLAMP_NUT_DIM,
		frame_screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		front = true,
	) {

	// back (higher than front)
	if (!front)
	mirror([1, 0])
	reflect(false, true)
	translate(frame_dim / 2)
	translate([frame_nut_dim[1] + frame_screw_surround, 0, clamp_thickness * 2 + boom_dim[2] - depth - PRINT_LAYER_HEIGHT * 3])
	children();

	// front
	if (front)
	reflect(false, true)
	translate(frame_dim / 2)
	translate([frame_nut_dim[1] + frame_screw_surround, 0, clamp_thickness + boom_dim[2] - clamp_depth])
	children();
}

module shape_canopy_clip(
		depth = CANOPY_CLIP_DEPTH,
	) {
	square(FRAME_HEIGHT * 2);
	polygon([
		[-depth, 0],
		[0, depth],
		[0, 0],
	]);
}
