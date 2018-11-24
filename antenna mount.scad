
include <_setup.scad>;
use <frame.scad>;

module shape_ant_mount_xy(
		ant_nut_dim = SMA_NUT_DIM,
		boom_angle = BOOM_ANGLE,
		boom_dim = BOOM_DIM,
		cam_dim = CAM_DIM,
		cam_pivot_offset = CAM_PIVOT_OFFSET,
		cam_pos = CAM_POS,
		cam_screw_dim = CAM_SCREW_DIM,
		fc_dim = FC_DIM,
		frame_nut_dim = FRAME_CLAMP_NUT_DIM,
		frame_screw_dim = FRAME_CLAMP_SCREW_DIM,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		thickness = ANT_MOUNT_THICKNESS,
		zip_tie_dim = ZIP_TIE_DIM,
	) {

	r = thickness / 2;

	module outer_part() {
		pos_ant(rot = [])
		translate([-r, ant_nut_dim[1] / 2 + thickness - r])
		circle_true(r);
	}

	difference() {
		union() {

			// angled portion
			reflect(x = false)
			hull() {
				scale([-1, 1])
				pos_frame_screws(reflect = [false, false], show = [true, false])
				circle(frame_nut_dim[1] / 2 + TOLERANCE_CLOSE + screw_surround);

				outer_part();
			}

			// straight portion
			hull()
			reflect(x = false)
			outer_part();
		}

		// battery wire zip tie hole
		*pos_frame_screws(reflect = [false, false], show = [true, false])
		translate([-screw_surround / 2, -(frame_nut_dim[1] + screw_surround)])
		rotate([0, 0, 90])
		square([zip_tie_dim[0] + TOLERANCE_CLEAR * 2, zip_tie_dim[1] + TOLERANCE_CLEAR * 2], true);
	}
}

module shape_ant_mount_yz(
		ant_nut_dim = SMA_NUT_DIM,
		ant_mount_surround = ANT_MOUNT_SURROUND,
		ant_pos = ANT_POS,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		smoothing = 1,
		offset_xy = 0,
		offset_z = 0,
		//thickness = ANT_MOUNT_THICKNESS,
		full_width = true,
	) {

	h = clamp_thickness + clamp_depth;
	r = ant_nut_dim[1] / 2 + ant_mount_surround;
	w = ant_nut_dim[1] + (ant_mount_surround + offset_xy) * 2;

	intersection() {
		smooth_acute(smoothing) {
			hull() {
				translate([ant_pos[2], 0])
				circle(r = r + offset_z);

				translate([FRAME_HEIGHT - h / 2, 0])
				square([h, w], true);
			}

			translate([FRAME_HEIGHT - h / 2, 0])
			square([h, 100], true);
		}

		if (!full_width)
		square([100, w + smoothing * 2], true);
	}
}

module ant_mount(
		ant_nut_dim = SMA_NUT_DIM,
		ant_mount_surround = ANT_MOUNT_SURROUND,
		ant_pos = ANT_POS,
		boom_dim = BOOM_DIM,
		clamp_depth = FRAME_CLAMP_DEPTH,
		clamp_thickness = FRAME_CLAMP_THICKNESS,
		offset_xy = 0,
		offset_z = 0,
		smoothing = 0.5,
		width,
	) {

	h = clamp_thickness + clamp_depth;
	z = clamp_thickness + boom_dim[2] - clamp_depth;

	intersection() {
		// vertical (ant mount) portion
		pos_ant(rot = [], z = false)
		rotate([0, -90])
		linear_extrude(20, center = true, convexity = 2)
		shape_ant_mount_yz(offset_xy = offset_xy, offset_z = offset_z);

		// horizontal (frame attachment) portion
		translate([0, 0, z])
		linear_extrude(20, convexity = 2)
		offset(r = offset_xy)
		smooth_acute(smoothing)
		shape_ant_mount_xy(offset_xy = offset_xy, offset_z = offset_z);
	}
}
