/*
 * control_status_lib.h
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_CONTROL_STATUS_LIB_H_
#define SRC_CONTROL_STATUS_LIB_H_

int read_reg(int reg_offset);
void write_control_reg(int reg_offset, int value);
void config_colour_lut(int no_of_colours);

#endif /* SRC_CONTROL_STATUS_LIB_H_ */
