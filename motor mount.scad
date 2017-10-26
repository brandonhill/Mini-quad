
include <_conf.scad>;
use <_setup.scad>;
use <frame.scad>;

module pos_motor_mount_screws(
		boom_angle = BOOM_FRAME_ANGLE,
		mount_screw_spacing = MOTOR_MOUNT_SCREW_SPACING,
	) {
	for (i = [0 : 3])
	rotate([0, 0, 45 + 90 * i])
	hull() {
		translate([mount_screw_spacing[0] / 2, 0])
		children();
		translate([mount_screw_spacing[1] / 2, 0])
		children();
	}
}

module motor_mount(
		boom_angle = BOOM_FRAME_ANGLE,
		boom_thickness = BOOM_THICKNESS,
		clamp_length = FRAME_CLAMP_LENGTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		height = BOOM_HEIGHT,
		landing_gear_height = LANDING_GEAR_HEIGHT,
		mount_outset = MOTOR_MOUNT_OUTSET,
		mount_rad = MOTOR_MOUNT_RAD,
		mount_screw_hole_rad = MOTOR_MOUNT_SCREW_HOLE_RAD,
		mount_screw_rad = MOTOR_MOUNT_SCREW_RAD,
		min_thickness = 0,
		mount_thickness = MOTOR_MOUNT_THICKNESS,
	) {

	module shape_motor_mount(
			clamps = true,
			edge = true,
			r = mount_rad,
		) {

		translate(-SIZE / 2)
		difference() {
			translate(SIZE / 2)
			difference() {
				smooth_acute(2) {
					circle(r);

					if (edge) {

						// motor protection
						rotate([0, 0, -90])
						arc(a = 270 - boom_angle, r1 = 0, r2 = mount_rad + mount_outset);

						// boom clamp
						if (clamps)
						rotate([0, 0, 180 + boom_angle])
						translate([0, mount_rad + mount_outset - clamp_thickness - boom_thickness / 2 - TOLERANCE_CLOSE])
						shape_frame_clamp(mount_rad);

						// strut clamp
						if (clamps)
						rotate([0, 0, 180])
						translate([0, -(mount_rad + mount_outset - clamp_thickness - boom_thickness / 2 - TOLERANCE_CLOSE)])
						shape_frame_clamp(mount_rad);
					}
				}
			}

			offset(r = TOLERANCE_CLOSE)
			diff_booms();

			offset(r = TOLERANCE_CLOSE)
			diff_struts();
		}
	}

	difference() {
		union() {

			// motor mount part
			translate([0, 0, landing_gear_height])
			linear_extrude(height, convexity = 3)
			shape_motor_mount(clamps = false);

			hull() {
				// motor mount part
				translate([0, 0, landing_gear_height])
				linear_extrude(0.1)
				shape_motor_mount(edge = false);

				// clamp/landing gear part
				hull()
				for(x = [0])//-1, 1])
				translate([(mount_rad * 1/2 - boom_thickness) * x, 0])
				cylinder(h = height + landing_gear_height, r = boom_thickness);
			}

			translate([0, 0, landing_gear_height]) {

				// boom clamp
				rotate([0, 0, 180 + boom_angle])
				translate([0, mount_rad + mount_outset - clamp_thickness - boom_thickness / 2 - TOLERANCE_CLOSE])
				translate([0, 0, height]) rotate([180, 0, 0]) // flip screws
				frame_clamp(mount_rad);

				// strut clamp
				rotate([0, 0, 180])
				translate([0, -(mount_rad + mount_outset - clamp_thickness - boom_thickness / 2 - TOLERANCE_CLOSE)])
				frame_clamp(mount_rad);
			}
		}

		// motor screws
		rotate([0, 0, boom_angle / 2]) {
			// holes
			translate([0, 0, 0.1])
			pos_motor_mount_screws()
			cylinder_true(h = height + landing_gear_height, r = mount_screw_rad + TOLERANCE_CLEAR);

			// countersinks
			translate([0, 0, -mount_thickness + min_thickness])
			pos_motor_mount_screws()
			cylinder_true(h = height + landing_gear_height, r = mount_screw_hole_rad);
		}
	}
}

motor_mount();
