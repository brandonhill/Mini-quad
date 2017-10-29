
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
		zip_tie_dim = ZIP_TIE_DIM,
	) {

	r = thickness / 2;
	w = nut_dim[1] + thickness;

	scale([-1, 1])
	difference() {
		union() {

			// angled portion
			reflect(x = false)
			hull() {
				pos_frame_screws(reflect = [false, false], show = [true, false])
				circle(frame_nut_dim[1] / 2 + TOLERANCE_CLOSE + screw_surround);

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

		// battery wire zip tie hole
		*pos_frame_screws(reflect = [false, false], show = [true, false])
		translate([-screw_surround / 2, -(frame_nut_dim[1] + screw_surround)])
		rotate([0, 0, 90])
		square([zip_tie_dim[0] + TOLERANCE_CLEAR * 2, zip_tie_dim[1] + TOLERANCE_CLEAR * 2], true);
	}
}
