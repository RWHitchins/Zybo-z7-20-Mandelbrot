/*
 * tpglib.c
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#include "tpglib.h"
#include "mandel_config.h"

//***************************************************************************
		//******************************** TPG **************************************
		//***************************************************************************

		void tpg_configure()
		{
			print("Configuring TPG...\n\r");
			print("Setting Active height to 1080 \n\r");
			memoryWrite32(TPG_BASE|TPG_ACTIVE_HEIGHT, VSIZE); 				// 1080
			print("Setting Active width to 1920 \n\r");
			print("\n\r");
			memoryWrite32(TPG_BASE|TPG_ACTIVE_WIDTH, HSIZE); 				// 1920
			memoryWrite32(TPG_BASE|TPG_MOTION_SPEED, 0x00000001);			// Amount to increase ramp patterns by each frame

			memoryWrite32(TPG_BASE|ENABLE_INPUT, 0x1);
			memoryWrite32(TPG_BASE|PASS_THRU_START_X, 0x0);
			memoryWrite32(TPG_BASE|PASS_THRU_START_Y, 0x0);
			memoryWrite32(TPG_BASE|PASS_THRU_END_X, HSIZE);
			memoryWrite32(TPG_BASE|PASS_THRU_END_Y, VSIZE);

			xil_printf("Setting pattern to: 0x%08x\n\r", TPG_PATTERN);
			memoryWrite32(TPG_BASE|TPG_BACKGND_PATTERN_ID, TPG_PATTERN); 	// PATTERN = Zone plate
			memoryWrite32(TPG_BASE|TPG_ZPLATE_HOR_CTRL_START, 0x00000008);			// Zone plate settings (if zone plate pattern is set)
			memoryWrite32(TPG_BASE|TPG_ZPLATE_HOR_CTRL_DELTA, 0x00000008);
			memoryWrite32(TPG_BASE|TPG_ZPLATE_VER_CTRL_START, 0x00000010);
			memoryWrite32(TPG_BASE|TPG_ZPLATE_VER_CTRL_DELTA, 0x00000010);

			print("Setting no foreground pattern...\n\r");
			memoryWrite32(TPG_FOREGND_PATTERN_ID, 0x00000000);  			// No foreground pattern
			print("Setting Colour format to RGB...\n\r");
			memoryWrite32(TPG_BASE|TPG_COLOUR_FORMAT, 0x00000000); 			// COLOUR FORMAT = RGB
			print("Setting free run mode...\n\r");
			memoryWrite32(TPG_BASE|TPG_CTRL, 0x01);		// START
			memoryWrite32(TPG_BASE|TPG_CTRL, 0x81); 	// FREE RUN MODE
		}
