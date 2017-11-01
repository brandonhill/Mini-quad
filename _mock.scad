
include <_setup.scad>;

MOCK_CAM_ANGLE = CAM_ANGLE; // test movement

PRINT_COLOUR_CANOPY = COLOUR_GREY_DARK;
PRINT_FRAME_COLOUR_BOT = COLOUR_GREY_DARK;
PRINT_FRAME_COLOUR_TOP = "lime";
PRINT_MOTOR_MOUNT_COLOUR_BOT = COLOUR_GREY_DARK;
PRINT_MOTOR_MOUNT_COLOUR_TOP = "lime";

include <antenna mount.scad>;
include <canopy.scad>;
include <frame.scad>;
include <landing gear.scad>;
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

//*
pos_landing_gear()
landing_gear(col = PRINT_FRAME_COLOUR_BOT);

translate([0, 0, LG_HEIGHT])
union() {
//	*
	mock_ant_conn();

//	*
	pos_ant()
	translate([0, 0, 12])
	5g_cp_antenna(30, wire_awg = ANT_WIRE_AWG);

//	*
	ant_clip(col = PRINT_FRAME_COLOUR_BOT)
	mock_rx_ant(pos = [0, 0, FRAME_HEIGHT - 4], rot = [-90, 0, 45]);

//	*
	mock_buzzer();

//	*
	mock_camera();

//	*
	pos_escs()
	mock_esc();

//	*
	translate([0, 0, FRAME_CLAMP_THICKNESS_BOT])
	mock_frame_stock();

//	*
%
//	color(PRINT_COLOUR_CANOPY)
	show_half(r = [0, 0, 0])//180])
	translate([0, 0, 0.1])
	canopy();

//*
	mock_fc();

//*
	union() {
//*
		translate([0, 0, BOOM_HEIGHT + FRAME_CLAMP_THICKNESS_BOT + FRAME_CLAMP_THICKNESS_TOP + 0.1])
		scale([1, 1, -1])
		frame(col = PRINT_FRAME_COLOUR_TOP, top = true);

//*
//%
		frame(col = PRINT_FRAME_COLOUR_BOT);
	}

//*
	mock_pdb();

//*
	mock_rx();

//*
	mock_vtx();
}

//*
translate([0, 0, LG_HEIGHT]) {
	reflect(x = false) {
		motor_mount(
			col = PRINT_MOTOR_MOUNT_COLOUR_BOT,
			front = true,
			top = false);

		translate([0, 0, BOOM_DIM[2] + FRAME_CLAMP_THICKNESS_BOT + FRAME_CLAMP_THICKNESS_TOP])
		scale([1, 1, -1])
		motor_mount(
			col = PRINT_MOTOR_MOUNT_COLOUR_TOP,
			front = true);
	}

	mirror([1, 0])
	reflect(x = false) {
		motor_mount(
			col = PRINT_MOTOR_MOUNT_COLOUR_BOT,
			top = false);

		translate([0, 0, BOOM_DIM[2] + FRAME_CLAMP_THICKNESS_BOT + FRAME_CLAMP_THICKNESS_TOP])
		scale([1, 1, -1])
		motor_mount(col = PRINT_MOTOR_MOUNT_COLOUR_TOP);
	}
}

//*
pos_motors() {

	translate([0, 0, LG_HEIGHT + FRAME_HEIGHT + 1]) {
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
	buzzer_piezo(h = dim[1], r = dim[0] / 2, pins = true, wires = false);
}

module mock_camera(
		angle = CAM_ANGLE,
		pivot_offset = CAM_PIVOT_OFFSET,
		pos = CAM_POS,
		rot = CAM_ROT,
	) {

	translate(pos)
//	rotate([0, -angle]) // pivot
	rotate([0, -rot[1] - MOCK_CAM_ANGLE])
	rotate(rot)
	translate([pivot_offset, 0]) // move back to pivot
	cam_runcam_swift_micro();
}

module pos_escs() {
	pos_booms()
	children();
}

module mock_esc(pos = ESC_POS, rot = ESC_ROT) {
	translate(pos)
	rotate(rot)
	color(COLOUR_GREY_DARK) {
		cube(ESC_DIM, true);

		translate([ESC_DIM[0] / 2 - ESC_CAP_DIM[1] / 2, 0, -(ESC_DIM[2] + ESC_CAP_DIM[0]) / 2])
		rotate([0, 90])
		cylinder(h = ESC_CAP_DIM[1], r = ESC_CAP_DIM[0] / 2, center = true);
	}
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

module mock_pdb(dim = PDB_DIM, rot = PDB_ROT) {
	translate([0, 0, FRAME_HEIGHT - dim[2] / 2 + TOLERANCE_FIT])
	rotate(rot)
	color(COLOUR_COPPER)
	cube(dim, true);
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

module mock_rx_ant(l = 40, pos = [], rot = []) {
	translate(pos)
	rotate(rot)
	color("gray")
	for (a = [0, 90])
	rotate([0, a])
	translate([0, 0, 6])
	cylinder(h = l, r = 0.5);
}

module mock_vtx(pos = VTX_POS, rot = VTX_ROT) {
	translate(pos)
	rotate(rot)
	vtx_vtx03();
}
