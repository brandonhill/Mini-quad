
include <_setup.scad>;
use <frame.scad>;

module shape_camera_mount(
		boom_dim = BOOM_DIM,
		cam_dim = CAM_DIM,
		cam_screw_dim = CAM_SCREW_DIM,
		mount_length = CAM_SCREW_DIM[0] + (TOLERANCE_CLOSE + CAM_SCREW_SURROUND) * 2,
		frame_nut_dim = FRAME_CLAMP_NUT_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = CAM_MOUNT_THICKNESS,
	) {

	module cam_surround(l = mount_length) {
		pos_camera(rot = [], z = false)
		difference() {
			square([l, cam_dim[0] + (TOLERANCE_FIT + thickness) * 2], true);
			square([boom_dim[0], cam_dim[0] + TOLERANCE_FIT * 2], true);
		}
	}

	cam_surround();

	reflect(x = false)
	hull() {
		pos_frame_screws(reflect = [false, false])
		circle(frame_nut_dim[1] / 2 + TOLERANCE_CLOSE + screw_surround);

		show_half(2d = true)
		translate([-(mount_length + 1) / 2, 0])
		cam_surround(l = 1);
	}
}
