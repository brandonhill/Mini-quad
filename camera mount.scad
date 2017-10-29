
include <_setup.scad>;
use <frame.scad>;

module shape_camera_mount(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		cam_dim = CAM_DIM,
		cam_pivot_offset = CAM_PIVOT_OFFSET,
		cam_pos = CAM_POS,
		cam_screw_dim = CAM_SCREW_DIM,
		clamp_width = FRAME_CLAMP_WIDTH,
		frame_nut_dim = FRAME_CLAMP_NUT_DIM,
		frame_screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
	) {

	difference() {

		// arms
		union() {

			// angled portion
			reflect(x = false)
			hull() {
				pos_frame_screws(reflect = [false, false], show = [true, false])
//				circle(frame_screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround);
				circle(frame_nut_dim[1] / 2 + TOLERANCE_CLEAR + screw_surround);

				pos_camera()
				translate([cam_pivot_offset / 2, cam_dim[0] / 2])
				circle(clamp_width);
			}

			// straight portion
			pos_camera(z = false)
			hull() {
				translate([cam_pivot_offset / 2, 0])
				translate([-1, 0])
				square([1, cam_dim[0] + (TOLERANCE_FIT + clamp_width) * 2], true);

				translate([cam_screw_dim[0] / 2 + TOLERANCE_CLEAR + screw_surround, 0])
				translate([-1, 0])
				square([1, cam_dim[0] + (TOLERANCE_FIT + clamp_width) * 2], true);
			}
		}

		// cam cutout
		pos_camera(z = false)
		square([boom_dim[0], cam_dim[0] + TOLERANCE_FIT * 2], true);
	}
}

shape_camera_mount();
