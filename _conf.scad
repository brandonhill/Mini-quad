
include <../BH-Lib/all.scad>;

TOLERANCE_CLOSE = 0.15;
TOLERANCE_FIT = 0.2;
TOLERANCE_CLEAR = 0.25;

// CONSTANTS

ANT_WIRE_RAD = 1.5;

BATT_2200_60C_DIM = [108, 34, 28];

ESC_CAP_DIM = [8, 13];
ESC_DIM = [25, 20, 5];

MOTOR_2204_DIM = [28, [7, 11, 12]];
MOTOR_2204_SHAFT_RAD = 5 / 2;
MOTOR_2204_SCREW_SPACING = [16, 19];
MOTOR_2204_SCREW_DEPTH = 4;
MOTOR_2204_CLEARANCE_DIM = [8, 2]; // dia, height

ZIP_TIE_DIM = [2.5, 1];

// CONFIG

PRINT_LAYER = 0.2;
PRINT_NOZZLE = 0.5;
FINAL_RENDER = false;

ANT_MOUNT_THICKNESS = 3;
ANT_CLIP_WIDTH = 10;
ANT_CLIP_THICKNESS = 1;
ANT_WIRE_AWG = 12;

BATT_DIM = BATT_2200_60C_DIM;
BATT_STRAP_DIM = [12, 3];

BOOM_ANGLE = 45; // best to keep this 45 to (maintain symmetry, and) minimize number of different parts
BOOM_HEIGHT = 15; // this is what your strips of CF are cut to..
BOOM_THICKNESS = 2; // thickness of your CF

BUZZER_DIM = [10, 6];

CAM_ANGLE = 25;
CAM_DIM = CAM_RUNCAM_SWIFT_MICRO_DIM;
CAM_HOUSING_DIM = [19, 19, 10];
CAM_PIVOT_OFFSET = CAM_RUNCAM_SWIFT_MICRO_PIVOT_OFFSET;
CAM_SCREW_DIM = SCREW_M2_SOCKET_DIM;

CANOPY_CAM_CUTOUT_RAD = CAM_RUNCAM_SWIFT_MICRO_RAD[2] + 1;
CANOPY_CLIP_WIDTH_BACK = 8;
CANOPY_CLIP_WIDTH_FRONT = 4;
CANOPY_ROUNDING = 4;
CANOPY_THICKNESS = 0.8;

COMPONENT_MOUNT_DIM = [8, 4];
COMPONENT_MOUNT_THICKNESS = 1;

CLEARANCE = 0.5; // clearance between components

FC_BOARD_THICKNESS = FC_OMNIBUS_F3_PRO_BOARD_THICKNESS;
FC_DIM = FC_OMNIBUS_F3_PRO_DIM; // Omnibus F3 Pro
FC_HOLE_SPACING = FC_OMNIBUS_F3_PRO_HOLE_SPACING;
FC_HOLE_RAD = FC_OMNIBUS_F3_PRO_HOLE_RAD;
FC_MOUNT_HEIGHT = 5;
FC_MOUNT_SCREW_DIM = SCREW_M3_SOCKET_DIM;
FC_MOUNT_THREAD_PITCH = THREAD_PITCH_M3_COARSE;

FRAME_DIM = [48, 48];
FRAME_CLAMP_NUT_DIM = NUT_M2_DIM;
FRAME_CLAMP_SCREW_DIM = SCREW_M2_SOCKET_DIM;
FRAME_CLAMP_SCREW_SURROUND = 2;
FRAME_CLAMP_THICKNESS_BOT = 2;
FRAME_CLAMP_THICKNESS_TOP = 3; // accommodate nut countersinks
FRAME_CLAMP_WIDTH = 2;
FRAME_PLATE_THICKNESS = 1;

LG_THICKNESS = 2;
LG_WIDTH = 10;

MOTOR_DIM = MOTOR_2204_DIM;
MOTOR_CLEARANCE_DIM = MOTOR_2204_CLEARANCE_DIM;
MOTOR_MOUNT_OUTSET = 2; // motor protection
MOTOR_OUTSET_ANGLE = 180; // amount of motor protection (deg)
MOTOR_MOUNT_RAD = MOTOR_DIM[0] / 2;
MOTOR_SCREW_SPACING = MOTOR_2204_SCREW_SPACING;
MOTOR_SCREW_DIM = SCREW_M3_SOCKET_DIM;
MOTOR_SCREW_LENGTH = 8;
MOTOR_SCREW_DEPTH = MOTOR_2204_SCREW_DEPTH; // amount of thread safe to screw into motor
MOTOR_SHAFT_RAD = 2.5;
MOTOR_MOUNT_THICKNESS = MOTOR_SCREW_LENGTH - MOTOR_SCREW_DEPTH;

PDB_DIM = [20, 20, 1.5];

PROP_RAD = 5 * MMPI / 2;

RX_DIM = RX_FRSKY_XM_PLUS_DIM;

SIZE_DIA = 185;

VTX_ANT_MOUNT_DIM = VTX_VTX03_ANT_MOUNT_DIM;
VTX_DIM = VTX_VTX03_DIM;

// SETUP

SIZE = [
	sin(90 - BOOM_ANGLE) * SIZE_DIA,
	cos(90 - BOOM_ANGLE) * SIZE_DIA
];

BOOM_LENGTH_NAT =
	sqrt(
		pow(SIZE[0] / 2, 2)
		+ pow(SIZE[1] / 2, 2)
	)
	- FRAME_CLAMP_WIDTH
	- TOLERANCE_FIT
	+ MOTOR_DIM[0] / 2
	;
BOOM_LENGTH = ceil(BOOM_LENGTH_NAT);
BOOM_LENGTH = 99; // maximize usage of 10x30cm stock

BOOM_DIM = [BOOM_LENGTH, BOOM_THICKNESS, BOOM_HEIGHT];

FRAME_HEIGHT = FRAME_CLAMP_THICKNESS_BOT + BOOM_DIM[2] + FRAME_CLAMP_THICKNESS_TOP;

ANT_POS = [-31, 0, FRAME_HEIGHT];
ANT_ROT = [0, -90];

BUZZER_POS = [0, -12, FRAME_CLAMP_THICKNESS_BOT + BATT_STRAP_DIM[1] + TOLERANCE_CLEAR + FRAME_CLAMP_SCREW_SURROUND / 2 + BUZZER_DIM[0] * 2/3];
BUZZER_ROT = [90, 0, 0];

CAM_POS = [
	FC_DIM[0] / 2 + CAM_DIM[2] / 2 + 3,
	0,
	FRAME_HEIGHT - (FRAME_CLAMP_THICKNESS_TOP + FRAME_CLAMP_THICKNESS_BOT) / 2];
CAM_ROT = [0, -CAM_ANGLE];

ESC_POS = [
	BOOM_LENGTH_NAT - MOTOR_MOUNT_RAD * 2 - ESC_DIM[0] / 2 - 16,
	(ESC_DIM[2] + BOOM_DIM[1]) / 2,
	(FRAME_HEIGHT - (FRAME_CLAMP_THICKNESS_TOP - FRAME_CLAMP_THICKNESS_BOT)) / 2
	];
ESC_ROT = [90, 180];

FC_POS = [0, 0, FRAME_HEIGHT + FC_BOARD_THICKNESS / 2 + FC_MOUNT_HEIGHT];
FC_ROT = [];

FRAME_ACC_WIDTH = FRAME_DIM[1] - (FRAME_CLAMP_WIDTH + BOOM_THICKNESS) * 3/2;
FRAME_CLAMP_SCREW_LENGTH = FRAME_HEIGHT + FRAME_CLAMP_SCREW_DIM[2] - FRAME_CLAMP_NUT_DIM[2];

RX_POS = [
		0,
		19,
		FRAME_HEIGHT - RX_DIM[1] / 2
	];
RX_ROT = [90, 0, 180];

CANOPY_CAM_HEIGHT = CAM_HOUSING_DIM[1] + (CANOPY_THICKNESS + 1) * 2;
CANOPY_CLIP_SPACING = FRAME_DIM[1] * 0.5;
CANOPY_CLIP_WIDTH = FRAME_DIM[1] * 0.25;
CANOPY_CLIP_FRONT_WIDTH = FRAME_ACC_WIDTH * 0.75;

PDB_ROT = [0, 0, 45];

//STRUT_DIM = [SIZE[0] - MOTOR_MOUNT_RAD * 2, BOOM_DIM[1], BOOM_DIM[2]];
STRUT_DIM = BOOM_DIM; // make life easy and keep all stock the same dimensions

STRUT_POS = [
	-(STRUT_DIM[0] / 2 / tan(BOOM_ANGLE) + sin(BOOM_ANGLE) * STRUT_DIM[1] + STRUT_DIM[1] / 2),
	-(STRUT_DIM[0] / 2 / tan(90 - BOOM_ANGLE) + sin(BOOM_ANGLE) * STRUT_DIM[1] + STRUT_DIM[1] / 2),
];

LG_DEPTH = STRUT_DIM[1] + (LG_THICKNESS + TOLERANCE_FIT) * 2;
LG_HEIGHT = BATT_DIM[2];

VTX_POS = [-18, 0, VTX_DIM[1] / 2];
VTX_ROT = [-90, 0, 90];

