
include <_setup.scad>;
use <frame.scad>;

module shape_ant_mount(
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		cam_dim = CAM_DIM,
		cam_pivot_offset = CAM_PIVOT_OFFSET,
		cam_pos = CAM_POS,
		cam_screw_dim = CAM_SCREW_DIM,
		fc_dim = FC_DIM,
		frame_nut_dim = FRAME_CLAMP_NUT_DIM,
		frame_screw_dim = FRAME_CLAMP_SCREW_DIM,
		nut_dim = SMA_NUT_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = ANT_MOUNT_THICKNESS,
	) {

	r = thickness / 2;
	w = nut_dim[1] + thickness;

	scale([-1, 1])
	difference() {

		// arms
		union() {

			// angled portion
			reflect(x = false)
			hull() {
				pos_frame_screws(reflect = [false, false], show = [true, false])
//				circle(frame_screw_dim[0] / 2 + TOLERANCE_FIT + screw_surround);
				circle(frame_nut_dim[1] / 2 + TOLERANCE_FIT + screw_surround);

				scale([-1, 1])
				pos_ant(rot = [])
				translate([-r, w / 2])
				circle(r);
			}

			// straight portion
			hull()
			reflect(x = false) {
				scale([-1, 1])
				pos_ant(rot = [])
				translate([-r, w / 2])
				circle(r);
			}
		}
	}
}

shape_ant_mount();
