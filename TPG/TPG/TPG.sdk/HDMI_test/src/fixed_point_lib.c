/*
 * fixed_point_lib.c
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#include "mandel_config.h"
#include "fixed_point_lib.h"
#include <stdio.h>
#include <math.h>


		unsigned long long float2fix(float n)
		{
		    unsigned long long int_part = 0, frac_part = 0;
		    int i;
		    float t;

		    int_part = (long long)floor(n) << FIXED_BIT;
		    n -= (long long)floor(n);
		    t = 0.5;
		    for (i = 0; i < FIXED_BIT; i++) {
		    	if ((n - t) >= 0) {
		    		n -= t;
		            frac_part += (1 << (FIXED_BIT - 1 - i));
		        }
		        t = t/2;
		    }
		    printf("int part = 0x%016llx\n\r",int_part);
		    printf("frac part= 0x%016llx\n\r",frac_part);
		    return int_part + (frac_part & 0x00000000FFFFFFFF);
		}

