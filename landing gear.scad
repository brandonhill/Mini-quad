
include <_setup.scad>;

module shape_landing_gear(
		boom_dim = BOOM_DIM,
		frame_clamp_depth = FRAME_CLAMP_DEPTH,
		frame_clamp_thickness = FRAME_CLAMP_THICKNESS,
		frame_clamp_width = FRAME_CLAMP_WIDTH,
		depth = LG_DEPTH,
		h = LG_HEIGHT,
		thickness = LG_THICKNESS,
	) {

	inset_bot = thickness;
	y = boom_dim[2] + TOLERANCE_FIT * 2;
	clamp_thickness = frame_clamp_thickness + frame_clamp_depth;
	clamp_width = boom_dim[1] + TOLERANCE_CLOSE * 2 + frame_clamp_width * 2;
	width = clamp_width + TOLERANCE_FIT * 2 + thickness;// * 2;

	module boom() {
		square([
			boom_dim[1] + TOLERANCE_FIT * 2,
			boom_dim[2] + TOLERANCE_FIT * 2], true);
	}

	module boom_clamp(width = clamp_width) {
		translate([0, -boom_dim[2] / 2])
		square([width, clamp_thickness], true);
	}

	module surround() {
		translate([0, -boom_dim[2] / 2])
		hull()
		reflect()
		translate([boom_dim[1] / 2 + frame_clamp_width, frame_clamp_depth])
		circle(width / 4);
	}

	difference() {

		// leg
		hull() {
			surround();

			translate([0, -(y / 2 + h + thickness / 2)])
			square(thickness, true);
		}

		boom();

		boom_clamp();

		// ease clip entry
		translate([0, clamp_thickness - thickness])
		hull() {
			translate([0, clamp_thickness])
			boom_clamp();
			boom_clamp(width = boom_dim[1] + TOLERANCE_FIT * 2);
		}
	}
}

module landing_gear(
		depth = LG_DEPTH,
		h = LG_HEIGHT,
		strut_dim = STRUT_DIM,
		thickness = LG_THICKNESS,
		width = LG_WIDTH,
	) {

	intersection() {
		linear_extrude(width, center = true, convexity = 2)
		shape_landing_gear();

		// round bottom
		hull()
		reflect(x = false)
		translate([0, -((strut_dim[2] + (TOLERANCE_FIT + thickness) * 2) / 2 + h - width / 2)])
		rotate([0, 90])
		cylinder_true(h = depth * 2, r = width / 2, center = true, $fn = 8);
	}
}
