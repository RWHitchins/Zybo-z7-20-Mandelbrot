/*
 * gpio.h
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_GPIOLIB_H_
#define SRC_GPIOLIB_H_

#define GPIO1_DATA							0x0
#define GPIO1_TRI							0x4
#define GPIO2_DATA							0x8
#define GPIO2_TRI							0xC

#define LED0								0x1
#define LED1								0x2
#define LED2								0x4
#define LED3								0x8


void flash_zybo_leds(int delay, int flash_no);
void check_clk_lock_status();


#endif /* SRC_GPIOLIB_H_ */
