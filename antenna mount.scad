
include <_conf.scad>;
use <_setup.scad>;
use <canopy.scad>;
use <frame.scad>;

module shape_antenna_mount(
		antenna_rad = ANT_HOLE_RAD,
		outset = ANT_MOUNT_OUTSET,
		surround = ANT_MOUNT_SURROUND,
		thickness = ANT_MOUNT_THICKNESS,
		width = FRAME_ACC_WIDTH,
	) {
	difference() {
		union() {
			smooth(2) {
				hull() {
					translate([0, outset - thickness / 2])
// 					circle(antenna_rad + TOLERANCE_CLEAR + surround);
					square((antenna_rad + TOLERANCE_CLEAR + surround) * 2, true);

// 					square([(antenna_rad + TOLERANCE_CLEAR + surround) * 2, thickness], true);
					square([width, thickness], true);
				}
// 				square([width, thickness], true);
			}
			square([width, thickness], true);
		}

		// antenna hole
		*translate([0, outset - thickness / 2])
		circle(antenna_rad + TOLERANCE_CLEAR);
	}
}

module antenna_mount(
		antenna_rad = ANT_HOLE_RAD,
		antenna_nut_rad = ANT_NUT_RAD,
		height = ANT_HOLE_HEIGHT,
		mount_height = BOOM_HEIGHT,
		nut_dim = ANT_MOUNT_NUT_DIM,
		outset = ANT_MOUNT_OUTSET,
		screw_dim = ANT_MOUNT_SCREW_DIM,
		screw_length = ANT_MOUNT_SCREW_LENGTH,
		support_thickness = ANT_SUPPORT_THICKNESS,
		surround = ANT_MOUNT_SURROUND,
		thickness = ANT_MOUNT_THICKNESS,
		width = FRAME_ACC_WIDTH,
	) {

	translate(-POS_FRAME_ACC_BACK) {
		difference() {
			union() {
				// antenna mount
				translate([0, 0, (mount_height - height) / 2])
				translate(POS_FRAME_ACC_BACK)
				rotate([0, 0, 90])
				linear_extrude(height, center = true, convexity = 2)
				shape_antenna_mount();

				// canopy clips
				translate(POS_FRAME_ACC_BACK)
				rotate([0, 0, 180])
				canopy_clips_back();

				// frame mount
				frame_acc_mount(nut_dim = nut_dim, screw_dim = screw_dim, screw_length = screw_length, mount_height = mount_height, pos = POS_FRAME_ACC_BACK, rot = [0, 0, 180], thickness = thickness);

				// supports - form lower nut keeper
				translate(POS_FRAME_ACC_BACK)
				for (y = [-1, 1])
				translate([-thickness / 2, (antenna_nut_rad + TOLERANCE_FIT + support_thickness / 2) * y])
				rotate([90, 0])
				linear_extrude(support_thickness, center = true)
				polygon([
					[-(antenna_rad + TOLERANCE_CLEAR + surround) * 2 + thickness / 2, mount_height / 2 - height],
					[0, -mount_height / 2],
					[0, mount_height / 2 - height],
				]);
			}

			// antenna hole
			translate([-(outset - thickness / 2), 0])
			translate(POS_FRAME_ACC_BACK)
			cylinder(h = mount_height + 0.2, r = antenna_rad + TOLERANCE_CLEAR, center = true);

			// antenna wire hole
			hull() {
				diff_frame_ant_wire_hole();
				translate([0, 0, -mount_height])
				diff_frame_ant_wire_hole();
			}
		}

		translate(POS_FRAME_ACC_BACK)
		translate([-(outset - thickness / 2), 0])
		children();
	}
}

antenna_mount();
