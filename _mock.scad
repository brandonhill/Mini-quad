
include <_setup.scad>;

MOCK_CAM_ANGLE = CAM_ANGLE; // test movement
MOCK_COMPONENTS = true;
MOCK_HARDWARE = false;

PRINT_COL_ALL = "lime";//alpha(COLOUR_BLUE_DARK, 0.5);

PRINT_COLOUR_BOOMS = COLOUR_CF;
PRINT_COLOUR_STRUTS = COLOUR_CF;
PRINT_COLOUR_CANOPY = PRINT_COL_ALL;
PRINT_FRAME_COLOUR_BOT = PRINT_COL_ALL;
PRINT_FRAME_COLOUR_TOP = PRINT_COL_ALL;
PRINT_MOTOR_MOUNT_COLOUR_BOT = PRINT_COL_ALL;
PRINT_MOTOR_MOUNT_COLOUR_TOP = PRINT_COL_ALL;

use <antenna mount.scad>;
use <canopy.scad>;
use <frame.scad>;
use <landing gear.scad>;
use <motor mount.scad>;

//$fs = 1;

print([
	"SIZE_DIA = ", SIZE_DIA
	, ", SIZE = ", SIZE
	, ", FRAME_CLAMP_SCREW_LENGTH = ", FRAME_CLAMP_SCREW_LENGTH
	, ", BOOM_ANGLE = ", BOOM_ANGLE
	, ", MOTOR_MOUNT_THICKNESS = ", MOTOR_MOUNT_THICKNESS
	, ", PROPS = ", PROP_RAD * 2 / MMPI, "\"/", PROP_RAD * 2, "mm"
	]);

print(["Booms = ", BOOM_DIM, ", natural = ", BOOM_LENGTH_NAT]);
print(["Struts = ", STRUT_DIM, ", natural = ", STRUT_LENGTH_NAT]);

*
pos_landing_gear()
landing_gear();

*mock_battery();

translate([0, 0, LG_HEIGHT]) {

	// DIM CHECK
	*#
	translate([0, 0, FRAME_HEIGHT / 2])
	cube([SIZE_DIA, SIZE_DIA, FRAME_HEIGHT], true);

	mock_ant_conn();

	if (MOCK_COMPONENTS)
	pos_ant()
	translate([0, 0, 12])
	5g_cp_antenna(30, wire_awg = ANT_WIRE_AWG);

	mock_buzzer();

	mock_camera();

	color(PRINT_COLOUR_CANOPY)
	show_half(r = [0, 0, 0])
	canopy();

	mock_escs();

	mock_fc();

	color(PRINT_FRAME_COLOUR_BOT)
	frame_bot();

	color(PRINT_FRAME_COLOUR_TOP)
	frame_top();

	*mock_battery_strap();

	mock_booms();

	mock_struts();

	// motor mounts
	reflect(x = false, y = true) {

		// front
		color(PRINT_MOTOR_MOUNT_COLOUR_BOT)
		motor_clamp(struts = [true, false]);
		color(PRINT_MOTOR_MOUNT_COLOUR_TOP)
		motor_mount(struts = [true, false]);

		if (MOCK_HARDWARE)
		pos_motor_clamp_screws(struts = [true, false], z = false) {
			translate([0, 0, FRAME_HEIGHT])
			% nut(FRAME_CLAMP_NUT_DIM);

			scale([1, 1, -1])
			% screw(dim = FRAME_CLAMP_SCREW_DIM, h = FRAME_CLAMP_SCREW_LENGTH, washer_dim = FRAME_CLAMP_WASHER_DIM);
		}

		// rear
		mirror([1, 0]) {
			color(PRINT_MOTOR_MOUNT_COLOUR_BOT)
			motor_clamp();
			color(PRINT_MOTOR_MOUNT_COLOUR_TOP)
			motor_mount();

			if (MOCK_HARDWARE)
			pos_motor_clamp_screws(z = false) {
				translate([0, 0, FRAME_HEIGHT])
				% nut(FRAME_CLAMP_NUT_DIM);

				scale([1, 1, -1])
				% screw(dim = FRAME_CLAMP_SCREW_DIM, h = FRAME_CLAMP_SCREW_LENGTH, washer_dim = FRAME_CLAMP_WASHER_DIM);
			}
		}
	}

	mock_rx();

	pos_rx_ant_mount_holes()
	mock_rx_ant(pos = [0, 0, 0], rot = [-120, 0, 0]);

	mock_vtx();

	pos_motors() {

		*motor_bumper();

		if (MOCK_COMPONENTS)
		% motor_soft_mount();

		translate([0, 0, MOTOR_SOFT_MOUNT_THICKNESS]) {

			mock_motor();

			translate([0, 0, sum(MOTOR_DIM[1]) - MOTOR_DIM[1][2] / 2])
			mock_prop();
		}
	}
}

module mock_ant_conn(pos = ANT_POS, rot = ANT_ROT) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	translate([0, 0, SMA_NUT_DIM[2] / 2])
	conn_rp_sma();
}

module mock_battery(dim = BATT_DIM) {
	if (MOCK_COMPONENTS)
	color("yellow")
	translate([0, 0, dim[2] / 2])
	% cube(dim, true);
}

module mock_battery_strap(dim = BATT_STRAP_DIM) {
	if (MOCK_COMPONENTS)
	translate([0, 0, FRAME_CLAMP_THICKNESS + FRAME_CLAMP_DEPTH + TOLERANCE_CLEAR + dim[1] / 2])
	% cube([dim[0], BATT_DIM[1] * 1.5, dim[1]], true);
}

module mock_booms() {
	color(PRINT_COLOUR_BOOMS)
	% diff_booms();
}

module mock_buzzer(dim = BUZZER_DIM, pos = BUZZER_POS, rot = BUZZER_ROT) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	buzzer_piezo(h = dim[1], r = dim[0] / 2, pins = true, wires = false);
}

module mock_camera() {
	if (MOCK_COMPONENTS)
	pos_camera(rot = [0, -MOCK_CAM_ANGLE])
	translate([CAM_PIVOT_OFFSET, 0])
	cam_runcam_swift_micro();
}

module mock_escs(pos = ESC_POS, rot = ESC_ROT) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	esc_racerstar_rs20ax4();
}

module mock_fc(pos = FC_POS, rot = FC_ROT) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	fc_omnibus_f3_pro();
}

module mock_motor(d = MOTOR_DIM, shaft_r = MOTOR_SHAFT_RAD) {
// 	% cylinder(h = h, r = r);
	if (MOCK_COMPONENTS)
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
	if (MOCK_COMPONENTS)
	%
	color("aqua")
	rotate_extrude()
	translate([r, 0])
	circle(0.1);
}

module mock_rx(dim = RX_DIM, pos = RX_POS, rot = RX_ROT) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	rx_frsky_xm_plus();
}

module mock_rx_ant(l = 40, pos = [], rot = []) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	color("gray")
//	for (a = [0, 90])
//	rotate([0, a])
//	translate([0, 0, 6])
	cylinder(h = l, r = 0.5);
}

module mock_struts() {
	color(PRINT_COLOUR_STRUTS)
	%	diff_struts(all = false);
}

module mock_vtx(pos = VTX_POS, rot = VTX_ROT) {
	if (MOCK_COMPONENTS)
	translate(pos)
	rotate(rot)
	vtx_vtx03(center = "board");
}
