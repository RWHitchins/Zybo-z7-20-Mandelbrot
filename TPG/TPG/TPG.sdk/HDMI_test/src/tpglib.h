/*
 * tpglib.h
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_TPGLIB_H_
#define SRC_TPGLIB_H_

#define TPG_CTRL							0x0
#define TPG_GLBL_INT_EN						0x4

#define TPG_PATTERN							0x0
/* PATTERN DEFINITIONS
	• 0x00 	- Pass the video input straight through the video output
	• 0x1 	- Horizontal Ramp which increases each component (RGB or Y) horizontally by 1
	• 0x2 	-Vertical Ramp which increases each component (RGB or Y) vertically by 1
	• 0x3 	- Temporal Ramp which increases every pixel by a value set in the motion_speed register for every frame.
	• 0x4 	- Solid red output
	• 0x5 	- Solid green output
	• 0x6 	- Solid blue output
	• 0x7 	- Solid black output
	• 0x8 	- Solid white output
	• 0x9 	- Color bars
	• 0xA 	- Zone Plate output produces a ROM based sinusoidal pattern.
			  This option has dependencies on the motion_speed, zplate_hor_cntl_start, zplate_hor_cntl_delta,
			  zplate_ver_cntl_start and zplate_ver_cntl_delta registers.
	• 0xB 	- Tartan Color Bars
	• 0xC 	- Draws a cross hatch pattern.
	• 0xD 	- Color sweep pattern
	• 0xE 	- A combined vertical and horizontal ramp
	• 0xF 	- Black and white checker board
	• 0x10 	- Pseudorandom pattern
	• 0x11 	- DisplayPort color ramp
	• 0x12 	- DisplayPort black and white vertical lines
	• 0x13 	- DisplayPort color square
*/
#define TPG_ACTIVE_HEIGHT					0x10
#define TPG_ACTIVE_WIDTH					0x18
#define TPG_BACKGND_PATTERN_ID				0x20
#define TPG_FOREGND_PATTERN_ID				0x28
#define TPG_MOTION_SPEED					0x38
#define TPG_COLOUR_FORMAT					0x40
#define TPG_ZPLATE_HOR_CTRL_START			0x58
#define TPG_ZPLATE_HOR_CTRL_DELTA			0x60
#define TPG_ZPLATE_VER_CTRL_START			0x68
#define TPG_ZPLATE_VER_CTRL_DELTA			0x70
#define PASS_THRU_START_X					0xa0
#define PASS_THRU_START_Y					0xa8
#define PASS_THRU_END_X						0xb0
#define PASS_THRU_END_Y						0xb8
#define ENABLE_INPUT						0x98


void tpg_configure();



#endif /* SRC_TPGLIB_H_ */
