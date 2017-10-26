
include <../BH-Lib/all.scad>;

// TODO: tidy up
TOLERANCE = 0.25;
TOLERANCE_CLOSE = 0.15;
TOLERANCE_FIT = 0.2;
TOLERANCE_CLEAR = 0.25;

// CONSTANTS

ANT_SMA_RAD = 6.19 / 2;
ANT_SMA_NUT_RAD = 7.67 / 2;

BATT_2200_60C_DIM = [108, 34, 28];

MOTOR_2204_DIM = [28, [7, 11, 12]];
MOTOR_2204_SHAFT_RAD = 5 / 2;
MOTOR_2204_SCREW_SPACING = [16, 19];
MOTOR_2204_SCREW_DEPTH = 4;

// CONFIG

PRINT_LAYER = 0.2;
PRINT_NOZZLE = 0.5;

ANT_HOLE_HEIGHT = 2;
ANT_HOLE_RAD = ANT_SMA_RAD;
ANT_NUT_RAD = ANT_SMA_NUT_RAD;
ANT_MOUNT_NUT_DIM = NUT_M2_DIM;
ANT_MOUNT_SCREW_DIM = SCREW_M2_DIM;
ANT_MOUNT_SCREW_LENGTH = 8;
ANT_MOUNT_SURROUND = 3;
ANT_MOUNT_THICKNESS = 3;
ANT_SUPPORT_THICKNESS = 2;
ANT_WIRE_HOLE_RAD = 3;

BATTERY_DIM = BATT_2200_60C_DIM;

MOTOR_ANGLE = 45;
BOOM_HEIGHT = 15; // this is what your strips of CF are cut to..
BOOM_THICKNESS = 2; // thickness of your CF

CAM_ANGLE = 35;
CAM_HOUSING_DIM = [19, 19, 10];
CAM_LENS_DIM = [[6, 3], [5, 3], [6, 3]]; // [rad, height]
CAM_MOUNT_ARM_THICKNESS = 3;
CAM_MOUNT_HEIGHT = 20;
CAM_MOUNT_NUT_DIM = NUT_M2_DIM;
CAM_MOUNT_SCREW_DIM = SCREW_M2_DIM;
CAM_MOUNT_SCREW_LENGTH = 8;
CAM_MOUNT_SCREW_SURROUND = 2;
CAM_MOUNT_THICKNESS = ANT_MOUNT_THICKNESS;
CAM_PIVOT_OFFSET = 9;
  CAM_MOUNT_OUTSET = max(CAM_MOUNT_THICKNESS / 2, 3);
CAM_SCREW_DIM = SCREW_M2_DIM;

CANOPY_CAM_CUTOUT_RAD = CAM_LENS_DIM[2][0] + 1;
CANOPY_CLIP_HEIGHT = 5;
CANOPY_CLIP_FRONT_LIP = 1;
CANOPY_CLIP_FRONT_THICKNESS = 1;
CANOPY_ROUNDING = 6;
CANOPY_THICKNESS = 1;

FRAME_DIM = [40, 40];
//FRAME_ACC_NUT_DIM = NUT_M2_DIM;
//FRAME_ACC_SCREW_DIM = SCREW_M2_DIM;
FRAME_ACC_SCREW_SPACING = FRAME_DIM[1] - 16;
FRAME_CLAMP_LENGTH = 10;
FRAME_CLAMP_NUT_DIM = NUT_M2_DIM;
FRAME_CLAMP_SCREW_DIM = SCREW_M2_DIM;
FRAME_CLAMP_THICKNESS = 3;
FRAME_PLATE_THICKNESS = 1;
FRAME_WALL_THICKNESS = 3;

MOTOR_DIM = MOTOR_2204_DIM;
MOTOR_MOUNT_OUTSET = 2; // motor protection
MOTOR_MOUNT_RAD = MOTOR_DIM[0] / 2;
MOTOR_MOUNT_SCREW_SPACING = MOTOR_2204_SCREW_SPACING;
MOTOR_MOUNT_SCREW_RAD = 1.5;
MOTOR_MOUNT_SCREW_HOLE_RAD = 4;
MOTOR_SCREW_LENGTH = 8;
MOTOR_SCREW_DEPTH = MOTOR_2204_SCREW_DEPTH; // amount of thread safe to screw into motor
MOTOR_MOUNT_THICKNESS = MOTOR_SCREW_LENGTH - MOTOR_SCREW_DEPTH;
MOTOR_SHAFT_RAD = MOTOR_2204_SHAFT_RAD;

PROP_RAD = 5 * MMPI / 2;

SIZE_DIA = 200;

STACK_DIM = [30, 30, 20];
STRAP_HOLE_DIM = [12, 3];

// SETUP

ANT_MOUNT_OUTSET = ANT_MOUNT_THICKNESS + ANT_HOLE_RAD + TOLERANCE_CLEAR + ANT_MOUNT_SURROUND;

SIZE = [
	sin(90 - MOTOR_ANGLE) * SIZE_DIA,
	cos(90 - MOTOR_ANGLE) * SIZE_DIA
];

MOTOR_FRAME_OFFSET = (SIZE - FRAME_DIM) / 2;

BOOM_LENGTH = sqrt(
		pow(MOTOR_FRAME_OFFSET[0], 2)
		+ pow(MOTOR_FRAME_OFFSET[1], 2)
	)
	- MOTOR_MOUNT_RAD
	- FRAME_WALL_THICKNESS
	- TOLERANCE_CLOSE * 2
	- 1 // TODO: do this right
	;

BOOM_FRAME_ANGLE = atan(MOTOR_FRAME_OFFSET[1] / MOTOR_FRAME_OFFSET[0])
	- atan((MOTOR_MOUNT_RAD
		+ MOTOR_MOUNT_OUTSET
		- FRAME_CLAMP_THICKNESS
		- BOOM_THICKNESS * 0.75
		- TOLERANCE_CLOSE) / (BOOM_LENGTH + MOTOR_MOUNT_RAD))
;
CAM_PROTRUSION = CAM_HOUSING_DIM[2] + CAM_LENS_DIM[0][1] + CAM_LENS_DIM[1][1] + CAM_LENS_DIM[2][1] - CAM_PIVOT_OFFSET;

CLAMP_WIDTH = BOOM_THICKNESS + (FRAME_CLAMP_THICKNESS + TOLERANCE_CLOSE) * 2;

FRAME_ACC_WIDTH = FRAME_DIM[1] - (FRAME_CLAMP_THICKNESS + BOOM_THICKNESS) * 3/2;

LANDING_GEAR_HEIGHT = BATTERY_DIM[2];

POS_FRAME_ACC_FRONT = [FRAME_DIM[0] / 2 + FRAME_CLAMP_THICKNESS + TOLERANCE_CLEAR + CAM_MOUNT_THICKNESS / 2, 0, BOOM_HEIGHT / 2];
POS_FRAME_ACC_BACK = [-(POS_FRAME_ACC_FRONT[0] - CAM_MOUNT_THICKNESS / 2 + ANT_MOUNT_THICKNESS / 2), POS_FRAME_ACC_FRONT[1], POS_FRAME_ACC_FRONT[2]];

STACK_POS = [0, 0, 5];

CANOPY_CAM_HEIGHT = CAM_HOUSING_DIM[1] + (CANOPY_THICKNESS + 1) * 2;
CANOPY_CLIP_SPACING = FRAME_DIM[1] * 0.5;
CANOPY_CLIP_WIDTH = FRAME_DIM[1] * 0.25;
CANOPY_CLIP_FRONT_WIDTH = FRAME_ACC_WIDTH * 0.75;

CANOPY_LENGTH = FRAME_DIM[0] + FRAME_WALL_THICKNESS * 2 + ANT_MOUNT_THICKNESS + CAM_MOUNT_THICKNESS + CAM_PROTRUSION + CAM_MOUNT_OUTSET;
CANOPY_HEIGHT_BACK = STACK_POS[2] + STACK_DIM[2] + CANOPY_ROUNDING;
CANOPY_HEIGHT_FRONT = BOOM_HEIGHT + CAM_MOUNT_HEIGHT + CANOPY_CAM_HEIGHT / 2;
CANOPY_ANGLE_TOP = atan((CANOPY_HEIGHT_FRONT - CANOPY_HEIGHT_BACK) / (CANOPY_LENGTH - ANT_MOUNT_THICKNESS - FRAME_WALL_THICKNESS - CANOPY_ROUNDING));


STRUT_LENGTH = SIZE[0]
	- MOTOR_MOUNT_RAD * 2 // manual optimize (fudge)
;
