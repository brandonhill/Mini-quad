
include <_conf.scad>;
include <_setup.scad>;

module canopy_clip_front(
		base = 0,
		lip = CANOPY_CLIP_FRONT_LIP,
		thickness = CANOPY_CLIP_FRONT_THICKNESS,
		width = CANOPY_CLIP_FRONT_WIDTH,
	) {

	translate([(lip - base) / 2, 0, thickness / 2])
	cube([base + lip, width, thickness], true);
}

module canopy_clip_back(
		width = CANOPY_CLIP_WIDTH,
		offset = 0,
	) {

	rotate([90, 0])
	linear_extrude(width + offset * 2, center = true, convexity = 2)
	shape_canopy_clip_back(offset = offset);
}

module canopy_clips_back(
		clip_width = CANOPY_CLIP_WIDTH,
		mount_height = BOOM_HEIGHT,
		offset = 0,
		spacing = CANOPY_CLIP_SPACING,
		thickness = ANT_MOUNT_THICKNESS,
		width = FRAME_ACC_WIDTH,
	) {
	translate([-thickness / 2, 0, mount_height / 2])
	for (y = [-1, 1])
	scale([1, y])
// 	translate([0, (width - clip_width) / 2])
	translate([0, spacing / 2])
	canopy_clip_back(clip_width, offset);
}

module shape_canopy_clip_back(
		height = CANOPY_CLIP_HEIGHT,
		lip = CANOPY_THICKNESS,
		offset = 0,
		thickness = ANT_MOUNT_THICKNESS - CANOPY_THICKNESS,
	) {

// 	smooth_acute(1)
	offset(r = offset)
	translate([thickness / 2, 0])
	{

		translate([0, height / 2])
		square([thickness, height], true);

		// clip
		translate([thickness / 2, height - lip])
		hull()
		for (x = [-thickness / 2, lip / 2])
		translate([x, 0])
		circle(lip);
	}
}

module solid_canopy(
		angle_top = CANOPY_ANGLE_TOP,
		ant_mount_thickness = ANT_MOUNT_THICKNESS,
		cam_area_height = CANOPY_CAM_HEIGHT,
		cam_cutout_rad = CANOPY_CAM_CUTOUT_RAD,
		cam_dim = CAM_HOUSING_DIM,
		cam_mount_thickness = CAM_MOUNT_THICKNESS,
		frame_acc_width = FRAME_ACC_WIDTH,
		frame_dim = FRAME_DIM,
		frame_height = BOOM_HEIGHT,
		frame_wall_thickness = FRAME_WALL_THICKNESS,
		height_back = CANOPY_HEIGHT_BACK,
		height_front = CANOPY_HEIGHT_FRONT,
		length = CANOPY_LENGTH,
		offset = 0,
		rounding = CANOPY_ROUNDING,
		stack_dim = STACK_DIM,
		stack_pos = STACK_POS,
		thickness = CANOPY_THICKNESS,
	) {

	h = cam_area_height + offset * 2;
	r = rounding + offset;

	frame_corner_pos = [
		frame_dim[0] / 2 + frame_wall_thickness - rounding + thickness,
		frame_dim[1] / 2 + frame_wall_thickness - rounding,
		frame_height];

	hull()
	difference() {
		union() {

			// camera clearance
			for (y = [-1, 1])
			translate([
				length / 2 + thickness,
				(cam_dim[0] - r) / 2 * y,
				height_front - h / 2 + offset])
			rotate([0, -angle_top])
			capsule(h, r, center = true);

			// stack clearance
			for (x = [-1, 1], y = [-1, 1])
			scale([x, y])
			translate([
				min(frame_corner_pos[0], stack_dim[0] / 2),
				min(frame_corner_pos[1], stack_dim[1] / 2),
				stack_pos[2] + stack_dim[2]])
			sphere(r);

			// bottom @ frame
			for (x = [-1, 1], y = [-1, 1])
			scale([x, y])
			translate([
				frame_corner_pos[0] + (x > 0 ? cam_mount_thickness + thickness : ant_mount_thickness),
				frame_corner_pos[1],
				frame_corner_pos[2]])
			sphere(r);
		}

		// cut off at top of frame
		translate([0, 0, -height_front / 2])
		translate([0, 0, BOOM_HEIGHT]) // put at top of frame edge
		cube([length * 2, frame_dim[1] * 2, height_front], true);
	}
}

module canopy(
		angle_top = CANOPY_ANGLE_TOP,
		cam_area_height = CANOPY_CAM_HEIGHT,
		cam_cutout_rad = CANOPY_CAM_CUTOUT_RAD,
		cam_mount_thickness = CAM_MOUNT_THICKNESS,
		clip_lip = CANOPY_CLIP_FRONT_LIP,
		frame_dim = FRAME_DIM,
		frame_height = BOOM_HEIGHT,
		height_front = CANOPY_HEIGHT_FRONT,
		length = CANOPY_LENGTH,
		thickness = CANOPY_THICKNESS,
	) {

	difference() {
		// canopy
		solid_canopy();
		solid_canopy(offset = -thickness);

		// camera cutout
// 		#
		translate([(length / 2 + cam_cutout_rad - thickness), 0, height_front - cam_cutout_rad])
		rotate([0, -angle_top])
		capsule(h = cam_area_height, r = cam_cutout_rad, center = true);

		// back clip cutouts
		translate(POS_FRAME_ACC_BACK)
		rotate([0, 0, 180])
		canopy_clips_back(offset = TOLERANCE_CLEAR);

		// motor wire holes
		for (x = [-1, 1], y = [-1, 1])
		translate([frame_dim[0] * 1/3 * x, 0, frame_height])
		rotate([90 * (y < 0 ? 1 : -1), 0])
		cylinder(h = frame_dim[1], r = x < 0 && y < 0 ? 5 : 4, $fn = 6);
	}

	// front clip
	translate(POS_FRAME_ACC_FRONT)
	translate([cam_mount_thickness / 2, 0, frame_height / 2])
	canopy_clip_front(base = clip_lip);
}

canopy();
