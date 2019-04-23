/*
 * complex_to_fixed.c
 *
 *  Created on: 13 Feb 2019
 *      Author: RWHitchins
 */
#include "complex_to_fixed.h"
#include "fixed_point_lib.h"


	Struct float_fixed(float fp_val_int)
	{
		Struct s;
		unsigned long long temp;
		unsigned long long result;
		temp = float2fix(fp_val_int);
		printf("INT OUTPUT => 0x%016llx\n\r",temp);
		s.integer_part    = (int)((temp >> 32) & 0x0000000F) ;
		s.fractional_part = (int)(temp & 0x00000000FFFFFFFF);
		return s;
	}


