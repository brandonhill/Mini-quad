
//PRINT_COLOUR = COLOUR_GREY_DARK;
PRINT_COLOUR = "Lime";

include <_conf.scad>;
use <_setup.scad>;
use <canopy.scad>;
include <frame.scad>;
include <motor mount.scad>;

print([
	"SIZE_DIA = ", SIZE_DIA
	, ", SIZE = ", SIZE
	, ", FRAME_CLAMP_SCREW_LENGTH = ", FRAME_CLAMP_SCREW_LENGTH
	, ", BOOM_ANGLE = ", BOOM_ANGLE
	, ", MOTOR_MOUNT_THICKNESS = ", MOTOR_MOUNT_THICKNESS
	, ", PROPS = ", PROP_RAD * 2 / MMPI, "\"/", PROP_RAD * 2, "mm"
	]);

print(["Booms = ", BOOM_DIM, ", natural = ", BOOM_LENGTH_NAT]);
print(["Struts = ", STRUT_DIM]);

*
mock_battery();

translate([0, 0, LANDING_GEAR_HEIGHT]) {
//*
	mock_ant_conn();

//*
	mock_buzzer();

//*
	mock_camera();

//*
	translate([0, 0, FRAME_CLAMP_THICKNESS_BOT])
	mock_frame_stock();

//*
//show_half()
%
	canopy();

//*
	mock_fc();

//*
	union() {
		translate([0, 0, BOOM_HEIGHT + FRAME_CLAMP_THICKNESS_BOT + FRAME_CLAMP_THICKNESS_TOP + 0.1])
		scale([1, 1, -1])
		frame(top = true);

//*
//%
		frame();
	}

//*
	pos_ant()
	translate([0, 0, 12])
	5g_cp_antenna(30);

//*
	mock_rx();

//*
	mock_vtx();
}

//*
translate([0, 0, LANDING_GEAR_HEIGHT]) {
	reflect(x = false) {
		motor_mount(front = true, top = false);

		translate([0, 0, BOOM_DIM[2] + FRAME_CLAMP_THICKNESS_BOT + FRAME_CLAMP_THICKNESS_TOP])
		scale([1, 1, -1])
		motor_mount(front = true);
	}

	mirror([1, 0])
	reflect(x = false) {
		motor_mount(top = false);

		translate([0, 0, BOOM_DIM[2] + FRAME_CLAMP_THICKNESS_BOT + FRAME_CLAMP_THICKNESS_TOP])
		scale([1, 1, -1])
		motor_mount();
	}
}

//*
pos_motors() {

	translate([0, 0, LANDING_GEAR_HEIGHT + FRAME_HEIGHT + 1]) {
//*
		mock_motor();

//		*
		translate([0, 0, sum(MOTOR_DIM[1]) - MOTOR_DIM[1][2] / 2]) {
			mock_prop();
		}
	}
}

module mock_ant_conn(pos = ANT_POS, rot = ANT_ROT) {
	translate(pos)
	rotate(rot)
	conn_rp_sma();
}

module mock_battery(dim = BATT_DIM) {
	color("yellow")
	translate([0, 0, dim[2] / 2])
	% cube(dim, true);
}

module mock_buzzer(dim = BUZZER_DIM, pos = BUZZER_POS, rot = BUZZER_ROT) {
	translate(pos)
	rotate(rot)
	buzzer_piezo(h = dim[1], r = dim[0] / 2, wires = false);
}

module mock_camera(
		angle = CAM_ANGLE,
		pivot_offset = CAM_PIVOT_OFFSET,
		pos = CAM_POS,
		rot = CAM_ROT,
	) {

	translate(pos)
//	rotate([0, -angle]) // pivot
	rotate(rot)
	translate([pivot_offset, 0]) // move back to pivot
	cam_runcam_swift_micro();
}

module mock_fc(pos = FC_POS, rot = FC_ROT) {
	translate(pos)
	rotate(rot)
	fc_omnibus_f3_pro();
}

module mock_frame_stock() {
	color(COLOUR_CF)
	% union() {
		diff_booms();
		diff_struts(all = false);
	}
}

module mock_motor(d = MOTOR_DIM, shaft_r = MOTOR_SHAFT_RAD) {
// 	% cylinder(h = h, r = r);
	motor_generic(
		height = d[1][1],
		rad = d[0] / 2,
		mount_arm_width = 0,
		mount_height = d[1][0],
		mount_rad = d[0] / 2,
		mount_holes = 0,
		mount_hole_rad = 2,
		mount_hole_thickness = 0,
		shaft_height = d[1][2],
		shaft_rad = shaft_r,
		col_bell = COLOUR_GREY_DARK,
		col_mount = COLOUR_GREY
	);
}

module mock_prop(r = PROP_RAD) {
	%
	color("aqua")
	rotate_extrude()
	translate([r, 0])
	circle(0.05);
}

module mock_rx(dim = RX_DIM, pos = RX_POS, rot = RX_ROT) {
	translate(pos)
	rotate(rot)
	rx_frsky_xm_plus();
}

module mock_vtx(pos = VTX_POS, rot = VTX_ROT) {
	translate(pos)
	rotate(rot)
	vtx_vtx03();
}
