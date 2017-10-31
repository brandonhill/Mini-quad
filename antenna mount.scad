
include <_setup.scad>;
use <frame.scad>;

module pos_ant_clip() {
	pos_struts(show = [true, false])
	children();
}

module ant_clip(
		ant_wire_awg = ANT_WIRE_AWG,
		clip_thickness = ANT_CLIP_THICKNESS,
		col,
		screw_surround = FRAME_CLAMP_SCREW_SURROUND,
		strut_dim = STRUT_DIM,
		width = ANT_CLIP_WIDTH,
		zip_tie_dim = ZIP_TIE_DIM,
	) {

	ant_wire_rad = wire_rad(ant_wire_awg);
	h = (clip_thickness + TOLERANCE_FIT) * 2 + strut_dim[1];
	l = (clip_thickness + TOLERANCE_FIT) * 2 + strut_dim[2];
	rx_ant_mount_outset = 3;

	color(col != undef ? col : undef)
	translate([0, 0, strut_dim[2] / 2 + FRAME_CLAMP_THICKNESS_BOT])
	difference() {
		pos_ant_clip()
		union() {

			// clip
			cube([width, h, l], true);

			// ant wire clip
			*translate([0, 0, l / 2 + min(clip_thickness, screw_surround + TOLERANCE_FIT)])
			rotate([90, 0])
			difference() {
				cylinder(h = h, r = ant_wire_rad + TOLERANCE_FIT + screw_surround, center = true);
				cylinder(h = h + 0.2, r = ant_wire_rad + TOLERANCE_FIT, center = true);
				rotate([0, 0, 45])
				pie(a = 90, r = ant_wire_rad + TOLERANCE_FIT + screw_surround + 0.2, h = h + 0.2);
			}

			// zip tie mounts
			translate([0, 0, l / 2 - clip_thickness * 1.5 - TOLERANCE_FIT])
			linear_extrude(clip_thickness * 1.5 + TOLERANCE_FIT)
			polygon([
				[-width / 2, -h / 2],
				[-width / 2, h / 2],
				[-(width / 2 - rx_ant_mount_outset), h / 2 + rx_ant_mount_outset],
				[width / 2 - rx_ant_mount_outset, h / 2 + rx_ant_mount_outset],
				[width / 2, h / 2],
				[width / 2, -h / 2],
			]);
		}

		// ant wire hole
		*pos_ant_clip()
		translate([0, 0, l / 2 + min(clip_thickness, screw_surround + TOLERANCE_FIT)])
		rotate([90, 0])
		cylinder(h = h * 4, r = ant_wire_rad + TOLERANCE_FIT, center = true);

		// strut cutout (keep printable
		pos_ant_clip()
		hull() {
			translate([0, -TOLERANCE_FIT / 2])
			cube([
				width + 0.2,
				strut_dim[1] + TOLERANCE_FIT,
				strut_dim[2] + TOLERANCE_FIT * 2], true);

			translate([0, clip_thickness / 2 - TOLERANCE_FIT])
			cube([
				width + 0.2,
				strut_dim[1] + TOLERANCE_FIT * 2,
				strut_dim[2] - clip_thickness], true);
		}

		// opening
		pos_ant_clip()
		translate([0, clip_thickness * 1.5, 0])
		hull() {
			cube([
				width + 0.2,
				h,
				strut_dim[2] - clip_thickness], true);
		}

		// zip tie holes
		pos_ant_clip()
		reflect(y = false)
		translate([width / 2 - 3, 2.5, l / 2 - clip_thickness / 2])
		rotate([0, 0, -45])
		linear_extrude(clip_thickness * 4, center = true)
		square([
			zip_tie_dim[0] + TOLERANCE_FIT * 2,
			zip_tie_dim[1] + TOLERANCE_FIT * 2], true);

		// weight savings
		r_cutout = width * 1/3;
		pos_ant_clip()
		hull()
		reflect(x = false, y = false, z = true)
		translate([0, 0, strut_dim[2] / 2 - width])
		rotate([90, 0])
		cylinder_true(h = 10, r = r_cutout, center = true, $fn = 8);
	}

	pos_ant_clip()
	children();
}

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
