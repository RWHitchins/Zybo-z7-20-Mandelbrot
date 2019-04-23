/*
 * render_image.c
 *
 *  Created on: 14 Feb 2019
 *      Author: RWHitchins
 */
#include "render_image.h"
#include "complex_to_fixed.h"
#include "control_status_lib.h"

void render_tile(float tlre, float tlim, float brre, float brim, int num_its)
{
	Struct tlreal,tlimag,brreal,brimag;

	tlreal	= float_fixed(tlre);
	tlimag	= float_fixed(tlim);
	brreal	= float_fixed(brre);
	brimag	= float_fixed(brim);

	printf("tlreal_integer_part     => 0x%08x\n\r",tlreal.integer_part);
	printf("tlreal_fractional_part  => 0x%08x\n\r",tlreal.fractional_part);
	printf("tlimag_integer_part     => 0x%08x\n\r",tlimag.integer_part);
	printf("tlimag_fractional_part  => 0x%08x\n\r",tlimag.fractional_part);
	printf("brreal_integer_part     => 0x%08x\n\r",brreal.integer_part);
	printf("brreal_fractional_part  => 0x%08x\n\r",brreal.fractional_part);
	printf("brimag_integer_part     => 0x%08x\n\r",brimag.integer_part);
	printf("brimag_fractional_part  => 0x%08x\n\r",brimag.fractional_part);


	write_control_reg(0x404,tlreal.fractional_part);	//ctrl_reg(1) tlre frac
	write_control_reg(0x408,tlreal.integer_part);		//ctrl_reg(2) tlre int
	write_control_reg(0x40c,tlimag.fractional_part);	//ctrl_reg(3) tlim frac
	write_control_reg(0x410,tlimag.integer_part);		//ctrl_reg(4) tlim int
	write_control_reg(0x414,brreal.fractional_part);	//ctrl_reg(5) brre frac
	write_control_reg(0x418,brreal.integer_part);		//ctrl_reg(6) brre int
	write_control_reg(0x41c,brimag.fractional_part);	//ctrl_reg(7) brim frac
	write_control_reg(0x420,brimag.integer_part);		//ctrl_reg(8) brim int

	read_reg(0x480);		//status_reg(0)
	read_reg(0x484);		//status_reg(1)

	write_control_reg(0x400,(0x80000000 + num_its));				// Specify max_its (bits 15 downto 0) and start (bit 31)
	write_control_reg(0x400,(0x00000000 + num_its));

}


void wait_for_ready()
{
	print("Waiting for image to be rendered ...\n\r");
	do
	{
	} while ((read_reg(0x480) & 1) == 0);
}
