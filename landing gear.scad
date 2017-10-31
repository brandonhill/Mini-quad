
include <_setup.scad>;

module shape_landing_gear(
		depth = LG_DEPTH,
		h = LG_HEIGHT,
		strut_dim = STRUT_DIM,
		thickness = LG_THICKNESS,
	) {

	inset_bot = thickness;
	y = strut_dim[2] + TOLERANCE_FIT * 2;

	module top() {
		translate([0, strut_dim[2] / 2])
		circle(depth / 2);
	}

	module surround() {
		union() {
			reflect(x = false)
			top();
		}
	}

	difference() {
		union() {

			surround();

			hull()
			difference() {
				surround();
				translate([50, 0])
				square(100, true);
			}

			// leg
			hull() {
				scale([1, -1])
				top();

				translate([thickness, -(y / 2 + h + thickness / 2)])
				square(thickness, true);
			}
		}

		// strut
		square([
			strut_dim[1] + TOLERANCE_FIT * 2,
			strut_dim[2] + TOLERANCE_FIT * 2], true);

		// access
		hull() {
			translate([strut_dim[1] / 4, -(thickness - inset_bot) / 2])
			square([
				strut_dim[1] / 2,
				strut_dim[2] + TOLERANCE_FIT * 2 - thickness - inset_bot], true);

			translate([strut_dim[1] + thickness, -thickness / 2])
			square([
				1,
				strut_dim[2] + TOLERANCE_FIT * 2 - thickness], true);
		}
	}
}

module landing_gear(
		col = undef,
		depth = LG_DEPTH,
		h = LG_HEIGHT,
		strut_dim = STRUT_DIM,
		thickness = LG_THICKNESS,
		width = LG_WIDTH,
	) {

	color(col)
	intersection() {
		linear_extrude(width, center = true, convexity = 2)
		shape_landing_gear();

		hull()
		reflect(x = false)
		translate([0, -((strut_dim[2] + (TOLERANCE_FIT + thickness) * 2) / 2 + h - width / 2)])
		rotate([0, 90])
		cylinder_true(h = depth * 2, r = width / 2, center = true, $fn = 8);
	}
}
