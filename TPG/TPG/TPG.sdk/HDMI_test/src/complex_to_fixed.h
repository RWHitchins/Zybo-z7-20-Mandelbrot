/*
 * complex_to_fixed.h
 *
 *  Created on: 13 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_COMPLEX_TO_FIXED_H_
#define SRC_COMPLEX_TO_FIXED_H_

struct fixed_result
{
	int integer_part, fractional_part;
};

typedef struct fixed_result Struct;


Struct float_fixed(float fp_val_int);


#endif /* SRC_COMPLEX_TO_FIXED_H_ */
