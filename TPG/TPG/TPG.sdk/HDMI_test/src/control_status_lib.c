/*
 * control_status_lib.c
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#include "mandel_config.h"
#include "control_status_lib.h"

		void config_colour_lut(int no_of_colours)
		{
			int red, green, blue;
			int col_step = no_of_colours/6;

			for (int rgb = 0; rgb <no_of_colours; rgb++) {
			    if (rgb <= col_step)
			    {
			    	red   = 0x00; //0xFF
			    	green = 0x00;
			    	blue  = 0x00  + rgb*6;
			    }
			    if (rgb >= (col_step) && (rgb <= 2*col_step ))
			    {
			    	red   = 0xFF - (rgb-col_step)*6;
			    	green = 0x00;
			    	blue  = 0xFF;
			    }
			    if (rgb >= (2*col_step) && (rgb <= 3*col_step ))
			    {
			    	red   = 0x00;
			    	green = 0x00  + (rgb-2*col_step)*6;
			    	blue  = 0xFF;
			    }
			    if (rgb >= (3*col_step) && (rgb <= 4*col_step ))
			    {
			    	red   = 0x00;
			    	green = 0xff;
			    	blue  =0xFF - (rgb-3*col_step)*6;
			    }
			    if (rgb >= (4*col_step) && (rgb <= 5*col_step ))
			    {
			    	red   = 0x00  + (rgb-4*col_step)*6;
			    	green = 0xff;
			    	blue  = 0x00;
			    }
			    if (rgb >= (5*col_step) && (rgb <= 6*col_step ))
			    {
			    	red   = 0x00; // 0xFF;
			    	green = 0xFF - (rgb-5*col_step)*6;
			    	blue  = 0x00;
			    }
			    //populate the 256 RGB entries in the LUT
			    memoryWrite32(AXI_SLAVE_BASE+rgb*4, ((red << 16) | ( green << 8) | blue ));
			    xil_printf("Address: 0x%08x RGB : 0x%08x\n\r", (AXI_SLAVE_BASE+rgb*4), ((red << 16) | ( green << 8) | blue)  );
			}

		}


		int read_reg(int reg_offset)
				{
					return memRead32(AXI_SLAVE_BASE+reg_offset);;
				}

		void write_control_reg(int reg_offset, int value)
				{
					memoryWrite32(AXI_SLAVE_BASE+reg_offset, value);
				}



