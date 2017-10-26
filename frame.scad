
include <_conf.scad>;
include <_setup.scad>;

module frame_acc_mount(
		nut_dim,
		screw_dim,
		screw_length,
		thickness,
		mount_height = BOOM_HEIGHT,
		screw_spacing = FRAME_ACC_SCREW_SPACING,
		pos = POS_FRAME_ACC_FRONT,
		rot = [],
		width = FRAME_ACC_WIDTH,
	) {

	difference() {
		translate(pos)
		rotate(rot)
		linear_extrude(mount_height, center = true)
		shape_frame_acc_mount(thickness);
		rotate(rot)
		frame_acc_screws(nut_dim, screw_dim, screw_length, thickness);
	}
}

module frame_acc_screws(
		nut_dim,
		screw_dim,
		screw_length,
		thickness,
		dim = FRAME_DIM,
		height = BOOM_HEIGHT,
		screw_spacing = FRAME_ACC_SCREW_SPACING,
		wall_thickness = FRAME_WALL_THICKNESS,
	) {

	nut_recess = 1;

	// screw/nut
	for (x = [1], y = [-1, 1])
	scale([x, y])
	translate([dim[0] / 2, screw_spacing / 2, height / 2]) {
		translate([wall_thickness + thickness + 0.2, 0])
		rotate([0, 90])
		screw_diff(screw_dim, screw_length, mock = true, tolerance = TOLERANCE_FIT);

		translate([-nut_dim[2] + nut_recess, 0])
		rotate([0, 90])
		nut_diff(nut_dim, mock = true, tolerance = TOLERANCE_CLOSE);
	}
}

module frame_clamp(
		base_thickness = FRAME_WALL_THICKNESS,
		clamp_length = FRAME_CLAMP_LENGTH,
		height = BOOM_HEIGHT,
		nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_spacing = BOOM_HEIGHT * 0.5,
		width = CLAMP_WIDTH,
	) {

	difference() {
		linear_extrude(height, convexity = 2)
		shape_frame_clamp(base_thickness);

		// screw
		for (z = [-1, 1])
		translate([base_thickness + clamp_length * 0.5, -width / 2, height / 2 + screw_spacing / 2 * z])
		rotate([90, 0])
		screw_diff(screw_dim, 10, mock = true, tolerance = TOLERANCE_FIT);

		// nut
		for (z = [-1, 1])
		translate([base_thickness + clamp_length * 0.5, width / 2 + nut_dim[2] - 1, height / 2 + screw_spacing / 2 * z])
		rotate([90, 0, 0])
		nut_diff(nut_dim, mock = true, tolerance = TOLERANCE_CLOSE);
	}
}

module shape_frame(
		wall_thickness = FRAME_WALL_THICKNESS,
	) {
	offset(r = wall_thickness)
	shape_frame_plate();
	shape_frame_clamps();
}

module shape_frame_acc_mount(
		thickness,
		frame_dim = FRAME_DIM,
		frame_wall_thickness = FRAME_WALL_THICKNESS,
	) {

	offset = (frame_dim[0] + thickness) / 2 + frame_wall_thickness;

	translate([-offset, 0])
	difference() {
		translate([offset, 0])
		square([thickness, frame_dim[0]], true);
		shape_frame();
	}
}

module shape_frame_clamp(
		base_thickness = FRAME_WALL_THICKNESS,
		boom_angle = BOOM_FRAME_ANGLE,
		clamp_length = FRAME_CLAMP_LENGTH,
		dim = FRAME_DIM,
		offset = FRAME_CLAMP_THICKNESS + TOLERANCE_CLOSE,
	) {

	translate([base_thickness, 0])
	difference() {
		union() {
			// clamp part, rounded
			offset(r = offset)
			translate([clamp_length / 2, 0])
			square([clamp_length - offset * 2, BOOM_THICKNESS], true);

			// square bottom
			translate([clamp_length / 4, 0])
			square([clamp_length / 2, BOOM_THICKNESS + offset * 2], true);

			// base
			translate([-base_thickness / 2, 0])
			square([base_thickness, BOOM_THICKNESS + offset * 2], true);
		}

		// slot
		offset(r = TOLERANCE_CLOSE)
		translate([clamp_length / 2, 0])
		square([clamp_length, BOOM_THICKNESS], true);
	}
}

module shape_frame_clamps(
		boom_angle = BOOM_FRAME_ANGLE,
		dim = FRAME_DIM,
		wall_thickness = FRAME_WALL_THICKNESS,
	) {
	for (x = [-1, 1], y = [-1, 1])
	scale([x, y])
	translate(dim / 2)
	rotate([0, 0, boom_angle])
	//translate([-dim[1] / 2 + wall_thickness, 0])
	shape_frame_clamp();
}

module shape_frame_plate(
		dim = FRAME_DIM,
	) {
	square(dim, true);
}

module frame(
		boom_angle = BOOM_FRAME_ANGLE,
		clamp_length = FRAME_CLAMP_LENGTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		dim = FRAME_DIM,
		height = BOOM_HEIGHT,
		plate_thickness = FRAME_PLATE_THICKNESS,
		strap_hole_dim = STRAP_HOLE_DIM,
		wall_thickness = FRAME_WALL_THICKNESS,
	) {

	module frame_clamps() {
		for (x = [-1, 1], y = [-1, 1])
		scale([x, y])
		translate(dim / 2)
		rotate([0, 0, boom_angle])
// 		translate([0, 0, 5])
		translate([-dim[1] / 2 + wall_thickness, 0])
		frame_clamp(dim[1] / 2);
	}

	difference() {
		union() {
			linear_extrude(height, convexity = 3)
			offset(r = wall_thickness) {
				shape_frame_plate();
			}

			frame_clamps();
		}

		// boom clamp slots
		translate([0, 0, -0.1])
		linear_extrude(height + 0.2)
		offset(r = TOLERANCE_CLOSE)
		shape_booms();

		// inner cavity
		translate([0, 0, plate_thickness])
		linear_extrude(height)
		shape_frame_plate();

		// ant. wire hole
		diff_frame_ant_wire_hole();

		// mounting holes
		translate([0, 0, -0.1])
		reflect() {
			translate([10, 10])
			cylinder(h = plate_thickness + 0.2, r = 1 + TOLERANCE_CLEAR);
			translate([15.25, 15.25])
			cylinder(h = plate_thickness + 0.2, r = 1 + TOLERANCE_CLEAR);
		}

		// strap holes
		rotate([90, 0])
		hull()
		for(x = [-1, 1])
		translate([strap_hole_dim[0] / 2 * x, plate_thickness + strap_hole_dim[1] / 2])
		cylinder(h = dim[1] + wall_thickness * 2 + 0.2, r = strap_hole_dim[1] / 2, center = true);

		*frame_acc_screws();
	}
}

frame();
