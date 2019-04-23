/*
	Roger Hitchins 2019
	TPG to VDMA to HDMI
	Using ZYBO Z7-20
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "memory_access.h"
#include "mandel_config.h"
#include "tpglib.h"
#include "tclib.h"
#include "vdmalib.h"
#include "gpiolib.h"
#include "fixed_point_lib.h"
#include "complex_to_fixed.h"
#include "render_image.h"

int main()
{
	// initialise the platform (built-in function)
	init_platform();
	print("\n\r");

	//***************************************************************************
	//******************************** Mandelbrot_main **************************
	//***************************************************************************

	// Set up the Test Pattern Generator
	tpg_configure();

	// Set up the Clock generator
	check_clk_lock_status();

	// Set up the Timing Controller
	get_tc_version();
	tc_reset();
	tc_start();
	get_tc_stats();

	//Flash the Zybo LEDs
	flash_zybo_leds(1000000,10);								// Flash the LEDs on the ZYBO


        
    //Set up the VDMA
	xil_printf("VDMA Version reg : 0x%08x\n\r", get_version());

	// Reset and Initialise the Stream-to-MemoryMapped VDMA system
	s2mm_reset();
	s2mm_initialise();
	// Start the s2mm VDMA
	s2mm_start_dma();

	// Reset and Initialise the MemoryMapped2stream VDMA system
	mm2s_reset();
	memoryWrite32(VDMA_BASE|OFF_VDMA_PARK_PTR_REG,0x00000301);
	mm2s_initialise();
	mm2s_start_dma();


	int num_its =256;
	// Configure the colour mapping LUT;
	config_colour_lut(256);										// program LUT with RGB colour values


	write_control_reg(0x424,0x0437077f);
	xil_printf("control reg 0x424 0x%08x\n\r", read_reg(0x424) );

	// setup initial position (entire set)
	float tlr = -1.1427110-0.1, tli =  0.43746;  // (tlr-brr)/(tli-bri) = 1.7 for correct aspect ratio
	float brr = -0.910, 		bri = 0.3;
	float window_width; 	//max -1.7 to 1.7 = 3.4
	float window_height;	//max  1.0 to-1.0 = 2.0

	// Mandel_top control registers
	//for (int i=0;i < 100;i+=2)
	{
		//render_tile(tlr*(100-i)/100,tli*(100-i)/100,brr*(100-i)/100,bri*(100-i)/100,num_its);
		//wait_for_ready();

		render_tile(-1.7,1.0,0.8,-0.5,num_its);
		wait_for_ready();

		render_tile(-1.7,1.0,0.4,-0.25,num_its);
		wait_for_ready();

		render_tile(-1.7,1.0,0.2,-0.125,num_its);
		wait_for_ready();

		render_tile(-1.7,1.0,0.1,-0.06125,num_its);
		wait_for_ready();

		render_tile(-1.7,1.0,1.7,-1,num_its);
		wait_for_ready();

	}
	//read_reg(0x400);
	write_control_reg(0x400,0x80000100);	// Specify max_its (bits 15 downto 0) and start (bit 31)
	//read_reg(0x400);
	write_control_reg(0x400,0x00000100);
	//read_reg(0x400);
	print("Finished...\n\r");

	cleanup_platform();
    return 0;
}
