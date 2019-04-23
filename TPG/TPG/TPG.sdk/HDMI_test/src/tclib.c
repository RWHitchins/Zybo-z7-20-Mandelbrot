/*
 * tclib.c
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#include "mandel_config.h"
#include "tclib.h"

		//***************************************************************************
		//******************************TIMING CONTROLLER ***************************
		//***************************************************************************

		void get_tc_version()
		{
			print("Timing Controller VERSION: ");
			memoryRead32(TC_BASE|TC_VERSION);
			print("\n\r");
		}

		void tc_reset()
		{
			print("Resetting Timing Controller...\n\r");
			memoryWrite32(TC_BASE|TC_CTRL, TC_CTRL_SW_RESET|TC_CTRL_ACTV_VID_POL_SRC |
					TC_CTRL_HSYNC_POL_SRC|TC_CTRL_VSYNC_POL_SRC|TC_CTRL_HBLANK_POL_SRC|TC_CTRL_VBLANK_POL_SRC|
					TC_CTRL_CHROMA_SRC|TC_CTRL_VBLANK_HOFF_SRC|TC_CTRL_VSYNC_END_SRC|
					TC_CTRL_VSYNC_START_SRC|TC_CTRL_ACTV_VSIZE_SRC|TC_CTRL_FRM_VSIZE_SRC|
					TC_CTRL_HSYNC_END_SRC|TC_CTRL_HSYNC_START_SRC|TC_CTRL_ACTV_HSIZE_SRC|TC_CTRL_FRM_HSIZE_SRC|
					TC_CTRL_GEN_ENABLE|TC_CTRL_REG_UPDATE|TC_CTRL_SW_ENABLE);		//0x81FFFF07
			// wait for reset to take place
			do {
				print(".\n\r");
			}
			while  ((memRead32(TC_BASE|TC_CTRL) & TC_CTRL_SW_RESET) == 1) ;
			print("Reset complete...\n\r");
		}

		void tc_start()
		{
			print("\n\r");
			print("Enabling Timing Controller...\n\r");
			memoryWrite32(TC_BASE|TC_CTRL, TC_CTRL_ACTV_VID_POL_SRC |
					TC_CTRL_HSYNC_POL_SRC|TC_CTRL_VSYNC_POL_SRC|TC_CTRL_HBLANK_POL_SRC|TC_CTRL_VBLANK_POL_SRC|
					TC_CTRL_CHROMA_SRC|TC_CTRL_VBLANK_HOFF_SRC|TC_CTRL_VSYNC_END_SRC|
					TC_CTRL_VSYNC_START_SRC|TC_CTRL_ACTV_VSIZE_SRC|TC_CTRL_FRM_VSIZE_SRC|
					TC_CTRL_HSYNC_END_SRC|TC_CTRL_HSYNC_START_SRC|TC_CTRL_ACTV_HSIZE_SRC|TC_CTRL_FRM_HSIZE_SRC|
					TC_CTRL_GEN_ENABLE); 		//0x01FFFF04
		}

		void get_tc_stats()
		{
			xil_printf("Generator HSIZE: 0x%08x\n\r", memRead32(TC_BASE|TC_GEN_HSIZE) );
			xil_printf("Generator VSIZE: 0x%08x\n\r", memRead32(TC_BASE|TC_GEN_VSIZE) );
			xil_printf("TC Status: 0x%08x\n\r", memRead32(TC_BASE|TC_STATUS));
			xil_printf("TC Error Reg: 0x%08x\n\r", memRead32(TC_BASE|TC_ERROR));
		}

