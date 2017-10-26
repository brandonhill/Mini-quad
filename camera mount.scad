
include <_conf.scad>;
use <_setup.scad>;
use <_mock.scad>;
use <frame.scad>;

module shape_camera_mount_profile(
		cam_outset = CAM_MOUNT_OUTSET,
		height = CAM_MOUNT_HEIGHT,
		mount_height = BOOM_HEIGHT,
		screw_rad = CAM_SCREW_DIM[0] / 2,
		screw_surround = CAM_MOUNT_SCREW_SURROUND,
		thickness = CAM_MOUNT_THICKNESS,
	) {

	cam_mount_surround_rad = screw_rad + TOLERANCE_CLEAR + screw_surround;

	smooth_acute(thickness / 2 - 0.001)
	union()
	{

		translate([0, height / 2 + mount_height * 0.5])
		square([thickness, height - mount_height * 0.25], true);

		// cam mount
		translate([-thickness / 2, mount_height / 2 + height - cam_mount_surround_rad])
		hull() {
			translate([cam_outset, 0])
			circle(cam_mount_surround_rad);
			translate([0, -height / 2])
			square([0.1, cam_mount_surround_rad * 2 + height], true);
		}
	}
}

module camera_mount(
		arm_thickness = CAM_MOUNT_ARM_THICKNESS,
		cam_cutout_depth = CAM_HOUSING_DIM[1] / 2 + CAM_MOUNT_SCREW_SURROUND + 5.5,
		cam_housing_width = CAM_HOUSING_DIM[0],
		cam_outset = CAM_MOUNT_OUTSET,
		canopy_clip_lip = CANOPY_CLIP_FRONT_LIP,
		canopy_clip_thickness = CANOPY_CLIP_FRONT_THICKNESS,
		canopy_clip_width = CANOPY_CLIP_FRONT_WIDTH,
		height = CAM_MOUNT_HEIGHT,
		mount_height = BOOM_HEIGHT,
		nut_dim = CAM_MOUNT_NUT_DIM,
		mount_screw_dim = CAM_MOUNT_SCREW_DIM,
		screw_dim = CAM_SCREW_DIM,
		screw_length = CAM_MOUNT_SCREW_LENGTH,
		screw_spacing = FRAME_ACC_SCREW_SPACING,
		screw_surround = CAM_MOUNT_SCREW_SURROUND,
		thickness = CAM_MOUNT_THICKNESS,
		width = FRAME_ACC_WIDTH,
	) {

	cam_cutout_width = cam_housing_width + TOLERANCE_CLEAR * 2;
	cam_mount_surround_rad = screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround;

	translate(-POS_FRAME_ACC_FRONT) {
		difference() {
			union() {
				translate(POS_FRAME_ACC_FRONT) {
					// cam mount (profile)
					rotate([90, 0])
					linear_extrude(cam_cutout_width + arm_thickness * 2, center = true, convexity = 2)
					shape_camera_mount_profile();

					// canopy clip surround
					translate([0, 0, mount_height / 2])
					rotate([0, 90])
					linear_extrude(thickness, center = true)
					rounded_square([canopy_clip_lip + arm_thickness * 2, width], 2, true);
				}

				// frame mount
				frame_acc_mount(nut_dim = nut_dim, screw_dim = mount_screw_dim, screw_length = screw_length, thickness = thickness);
			}

			// camera cutout
			translate(POS_FRAME_ACC_FRONT)
			translate([cam_outset / 2, 0, height + mount_height / 2])
			rotate([0, 90])
			linear_extrude(thickness + cam_outset + cam_mount_surround_rad + 0.2, center = true)
			rounded_square([cam_cutout_depth * 2, cam_cutout_width], 1);

			// pivot screw holes
			translate(POS_FRAME_ACC_FRONT)
			translate([cam_outset - thickness / 2, 0, height + mount_height / 2 - cam_mount_surround_rad])
			rotate([90, 0])
			cylinder(h = width + 0.2, r = screw_dim[0] / 2 + TOLERANCE_CLOSE, center = true);

			// canopy clip hole
			translate(POS_FRAME_ACC_FRONT)
			translate([thickness / 2, 0, mount_height / 2 + canopy_clip_thickness / 2])
			rotate([0, 0])
			cube([(canopy_clip_lip + TOLERANCE_CLEAR) * 2, canopy_clip_width + TOLERANCE_CLEAR * 2, canopy_clip_thickness + TOLERANCE_CLEAR * 2], true);
		}

		translate(POS_FRAME_ACC_FRONT)
		translate([cam_outset, 0, height + mount_height / 2 - cam_mount_surround_rad])
		children();
	}
}

camera_mount()
mock_camera();
