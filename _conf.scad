/**
 * TODO:
 * NICE TO HAVE:
 * - bevel top clamp portion of motor mounts
 */

include <../BH-Lib/all.scad>;

PRINT_LAYER_HEIGHT = 0.2;
PRINT_NOZZLE_DIA = 0.5;

TOLERANCE_CLOSE = 0.15;
TOLERANCE_FIT = 0.2;
TOLERANCE_CLEAR = 0.25;

// CONSTANTS

ANT_WIRE_RAD = 1.5;

BATT_2200_60C_DIM = [108, 34, 28];

/*MOTOR_2204_DIM = [28, [7, 11, 12]];* /
MOTOR_2204_HEIGHT = 18;
MOTOR_2204_RAD = 14;
MOTOR_2204_SHAFT_RAD = 5 / 2;
MOTOR_2204_SCREW_SPACING = [16, 19];
MOTOR_2204_SCREW_DEPTH = 4;
MOTOR_2204_CLEARANCE_DIM = [8, 2]; // dia, height
*/

ZIP_TIE_DIM = [2.5, 1];

// CONFIG

ANT_MOUNT_SURROUND = 2;
ANT_MOUNT_THICKNESS = 3;
ANT_WIRE_AWG = 12;

BATT_DIM = BATT_2200_60C_DIM;
BATT_STRAP_DIM = [15, 3];

BOOM_ANGLE = 45;
BOOM_HEIGHT = 11;
BOOM_THICKNESS = 1.9;
STRUT_THICKNESS = 0.95;

BUZZER_DIM = [10, 6];

CAM_ANGLE = 25;
CAM_MOUNT_THICKNESS = 2;
CAM_DIM = CAM_RUNCAM_SWIFT_MICRO_DIM;
CAM_HOUSING_DIM = CAM_RUNCAM_SWIFT_MICRO_HOUSING_DIM;//[19, 19, 10];
CAM_PIVOT_OFFSET = CAM_RUNCAM_SWIFT_MICRO_PIVOT_OFFSET;
CAM_SCREW_DIM = SCREW_M2_SOCKET_DIM;
CAM_SCREW_SURROUND = 2;

CANOPY_CAM_CUTOUT_RAD = CAM_RUNCAM_SWIFT_MICRO_RAD[2] + 1;
CANOPY_CAM_OUTSET = 1;
CANOPY_CLIP_DEPTH = 1.5;
CANOPY_CLIP_WIDTH = 5;
CANOPY_ROUNDING = 4;
CANOPY_THICKNESS = 1;

COMPONENT_MOUNT_DIM = [8, 4];
COMPONENT_MOUNT_THICKNESS = 1;

CLEARANCE = 1; // clearance between components

ESC_BOARD_DIM = ESC_RACERSTAR_RS20AX4_BOARD_DIM;
ESC_DIM = ESC_RACERSTAR_RS20AX4_DIM;

FC_BOARD_THICKNESS = FC_OMNIBUS_F3_PRO_BOARD_DIM[2];
FC_DIM = FC_OMNIBUS_F3_PRO_DIM;
FC_HOLE_SPACING = FC_OMNIBUS_F3_PRO_HOLE_SPACING;
FC_HOLE_RAD = FC_OMNIBUS_F3_PRO_HOLE_RAD;
FC_MOUNT_SCREW_DIM = SCREW_M3_SOCKET_DIM;
FC_MOUNT_SCREW_SURROUND = 1.5;
FC_MOUNT_THREAD_PITCH = THREAD_PITCH_M3_COARSE;
FC_STANDOFF_HEIGHT = 7;

FRAME_CLAMP_DEPTH = 2;
FRAME_CLAMP_LENGTH = 12;
FRAME_CLAMP_NUT_DIM = NUT_M2_DIM;
FRAME_CLAMP_SCREW_DIM = SCREW_M2_SOCKET_DIM;
FRAME_CLAMP_SCREW_SURROUND = 2;
FRAME_CLAMP_THICKNESS = 3;
FRAME_CLAMP_WASHER_DIM = false;//WASHER_M2_DIM;
FRAME_CLAMP_WIDTH = 3;
FRAME_COMPONENT_MOUNT_THICKNESS = 1;
FRAME_DIM = [36.8, 36.8]; // depends on stack mounts and boom angle, so need to configure manually

LG_THICKNESS = 2;
LG_WIDTH = 10;

MOTOR_BUMPER_RET_THICKNESS = 1; // thinnest amount of material surrounding motor mount end screw
MOTOR_CLAMP_SCREW_SINGLE_OUTER = false;
MOTOR_CLEARANCE_DIM = [MOTOR_EACHINE_2204_MOUNT_AXLE_RAD * 2, MOTOR_EACHINE_2204_MOUNT_AXLE_DEPTH];
MOTOR_HEIGHT = MOTOR_EACHINE_2204_HEIGHT;
MOTOR_MOUNT_OUTSET = 2; // motor protection (via soft mount)
MOTOR_MOUNT_RAD = MOTOR_EACHINE_2204_MOUNT_RAD;
MOTOR_OUTSET_ANGLE = 180; // amount of motor protection (deg)
MOTOR_RAD = MOTOR_EACHINE_2204_RAD;
MOTOR_SCREW_DEPTH = MOTOR_EACHINE_2204_MOUNT_HOLE_DEPTH; // amount of thread safe to screw into motor
MOTOR_SCREW_DIM = MOTOR_EACHINE_2204_MOUNT_SCREW_DIM;
MOTOR_SCREW_LENGTH = 8;
MOTOR_SHAFT_RAD = MOTOR_EACHINE_2204_SHAFT_RAD;
MOTOR_SOFT_MOUNT_THICKNESS = 1;
MOTOR_MOUNT_THICKNESS = print_height(MOTOR_SCREW_LENGTH - MOTOR_SCREW_DEPTH - MOTOR_SOFT_MOUNT_THICKNESS * 0.5);

PDB_DIM = [20, 20, 1.5];

PROP_RAD = 5 * MMPI / 2;

RX_ANT_MOUNT_SURROUND = 2;
RX_DIM = RX_FRSKY_XM_PLUS_DIM;

SIZE_DIA = 185;

STACK_MOUNT_HEIGHT = 6;

VTX_ANT_MOUNT_DIM = VTX_VTX03_ANT_MOUNT_DIM;
VTX_DIM = VTX_VTX03_DIM;
VTX_BOARD_THICKNESS = VTX_VTX03_BOARD_DIM[2];

// SETUP

SIZE = [
	sin(90 - BOOM_ANGLE) * SIZE_DIA,
	cos(90 - BOOM_ANGLE) * SIZE_DIA
];

BOOM_OUTSET =
	BATT_STRAP_DIM[0] / 2 / cos(BOOM_ANGLE) // battery strap portion
	+ BOOM_THICKNESS / 2 / tan(90 - BOOM_ANGLE); // boom thickness portion
BOOM_LENGTH_NAT =
	SIZE_DIA / 2 + MOTOR_RAD

	// battery strap clearance
	- BOOM_OUTSET

	// motor clamp end screw, bumper retention
	- (
		FRAME_CLAMP_SCREW_SURROUND
		- max(FRAME_CLAMP_NUT_DIM[1], FC_MOUNT_SCREW_DIM[1]) / 2
	)
	;
BOOM_LENGTH = floor(BOOM_LENGTH_NAT);

FRAME_CLAMP_SCREW_LENGTH_NAT = (FRAME_CLAMP_WASHER_DIM ? FRAME_CLAMP_WASHER_DIM[2] : 0) + FRAME_CLAMP_THICKNESS + BOOM_HEIGHT + FRAME_CLAMP_THICKNESS + FRAME_CLAMP_NUT_DIM[2];
FRAME_CLAMP_SCREW_LENGTH = round(FRAME_CLAMP_SCREW_LENGTH_NAT / 2) * 2;

BOOM_DIM = [BOOM_LENGTH, BOOM_THICKNESS, BOOM_HEIGHT - (FRAME_CLAMP_SCREW_LENGTH_NAT - FRAME_CLAMP_SCREW_LENGTH)];

FRAME_HEIGHT = FRAME_CLAMP_THICKNESS + BOOM_DIM[2] + FRAME_CLAMP_THICKNESS;
//FRAME_HEIGHT = FRAME_CLAMP_SCREW_LENGTH - (FRAME_CLAMP_WASHER_DIM ? FRAME_CLAMP_WASHER_DIM[2] : 0);

ANT_POS = [-30, 0, FRAME_CLAMP_THICKNESS + BOOM_DIM[2] - FRAME_CLAMP_DEPTH + SMA_NUT_DIM[0] / 2 + TOLERANCE_CLEAR + ANT_MOUNT_SURROUND];
ANT_ROT = [0, -90];

BATT_MOUNT_WIDTH = FRAME_DIM[1] + FRAME_CLAMP_WIDTH;

BUZZER_POS = [0, -12.5, FRAME_CLAMP_THICKNESS + BOOM_HEIGHT + BUZZER_DIM[1] / 2];
BUZZER_ROT = [180, 0];//90, 0, 0];

CAM_POS = [
	FC_DIM[0] / 2 + CAM_DIM[2] / 2 + 3,
	0,
	FRAME_HEIGHT - (FRAME_CLAMP_THICKNESS + FRAME_CLAMP_DEPTH) / 2];
CAM_ROT = [0, -CAM_ANGLE];

ESC_POS = [0, 0, FRAME_HEIGHT + STACK_MOUNT_HEIGHT];
ESC_ROT = [];

FC_POS = [0, 0, ESC_POS[2] + ESC_BOARD_DIM[2] + FC_STANDOFF_HEIGHT];
FC_ROT = [];

//FRAME_ACC_WIDTH = FRAME_DIM[1] - (FRAME_CLAMP_WIDTH + BOOM_THICKNESS) * 3/2;

RX_ANT_MOUNT_DIM = [
	ZIP_TIE_DIM[0] + (TOLERANCE_CLEAR + RX_ANT_MOUNT_SURROUND) * 2,
	ZIP_TIE_DIM[1] + (TOLERANCE_CLEAR + RX_ANT_MOUNT_SURROUND) * 2];
RX_POS = [
		0,
		17.5,
		FRAME_HEIGHT - (FRAME_CLAMP_THICKNESS + FRAME_CLAMP_DEPTH) / 2,// - RX_DIM[1] / 2
		//FRAME_CLAMP_THICKNESS + BOOM_HEIGHT - 2
	];
RX_ROT = [90, 0, 180];

CANOPY_CAM_HEIGHT = CAM_HOUSING_DIM[1] + (CANOPY_THICKNESS + 1) * 2;

MOTOR_BUMPER_HEIGHT = BOOM_DIM[2] - (MOTOR_MOUNT_THICKNESS - FRAME_CLAMP_THICKNESS) + FRAME_CLAMP_THICKNESS + FRAME_CLAMP_SCREW_DIM[2];

PDB_ROT = [0, 0, 45];

STRUT_LENGTH_NAT = SIZE[0] - MOTOR_RAD * 2;
//STRUT_LENGTH = ceil(STRUT_LENGTH_NAT);
STRUT_LENGTH = 100; // for ease of cutting from stock
STRUT_DIM = [STRUT_LENGTH, STRUT_THICKNESS, BOOM_DIM[2]];
//STRUT_DIM = BOOM_DIM; // make life easy and keep all stock the same dimensions

STRUT_POS = [
	-(STRUT_DIM[0] / 2 / tan(BOOM_ANGLE) + sin(BOOM_ANGLE) * BOOM_DIM[1] + STRUT_DIM[1] / 2),
	-(STRUT_DIM[0] / 2 / tan(90 - BOOM_ANGLE) + sin(BOOM_ANGLE) * BOOM_DIM[1] + STRUT_DIM[1] / 2),
];
BOOM_STRUT_JOINT = STRUT_DIM[0] / 2 / cos(BOOM_ANGLE);

LG_DEPTH = STRUT_DIM[1] + (LG_THICKNESS + TOLERANCE_FIT) * 2;
LG_HEIGHT = BATT_DIM[2];

VTX_POS = [-17, 0, VTX_DIM[1] / 2];
VTX_ROT = [-90, 0, 90];
//VTX_POS = [-24, 0, BOOM_DIM[2] - VTX_DIM[2] / 2];
//VTX_ROT = [0, 180, 90];
