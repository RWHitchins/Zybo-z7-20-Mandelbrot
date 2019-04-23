/*
 * mandel_config.h
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_MANDEL_CONFIG_H_
#define SRC_MANDEL_CONFIG_H_

#define VSIZE								0x00000438  // 1080
#define HSIZE								0x00000780  // 1920


#define GPIO_BASE							0x41200000
#define VDMA_BASE                     		0x43000000
#define TPG_BASE							0x43C00000
#define TC_BASE								0x43C10000
#define AXI_SLAVE_BASE						0x60000000


#define FIXED_BIT 32

#endif /* SRC_MANDEL_CONFIG_H_ */
