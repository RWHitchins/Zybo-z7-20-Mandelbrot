/*
 * gpiolib.c

 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */
#include "mandel_config.h"
#include "gpiolib.h"

		void flash_zybo_leds(int delay, int flash_no)
		{
			memoryWrite32(GPIO_BASE|GPIO1_TRI, 0x00000000);		//set GPIO port1 TRISTATE to outputs
			memoryWrite32(GPIO_BASE|GPIO2_TRI, 0x0000000f);  	//set GPIO port2 to inputs

			for(int flash=0; flash < flash_no; flash++)
				{
			    	memoryWrite32(GPIO_BASE|GPIO1_DATA, LED0);// turn on LED 0
			    	for(int j=0;j < delay;j++){}
					memoryWrite32(GPIO_BASE|GPIO1_DATA, LED1);// turn on LED 1
					for(int j=0;j < delay;j++){}
					memoryWrite32(GPIO_BASE|GPIO1_DATA, LED2);// turn on LED 2
					for(int j=0;j < delay;j++){}
					memoryWrite32(GPIO_BASE|GPIO1_DATA, LED3);// turn on LED 3
					for(int j=0;j < delay;j++){}
				}
			memoryWrite32(GPIO_BASE|GPIO1_DATA, 0x0);											// turn LEDs off
		}

		void check_clk_lock_status()
		{
			print("Waiting for clock to stabilise... \n\r");
			do {
					print(".\n\r");
				}
			while  ((memRead32(GPIO_BASE|GPIO2_DATA) & 0x1) == 0) ;				// bitwise AND
			print("MMCM Locked\n\r");
		}

