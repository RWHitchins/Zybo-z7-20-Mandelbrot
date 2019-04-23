/*
 * vdmalib.c
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#include "mandel_config.h"
#include "vdmalib.h"

		//1. Write control information to the channel VDMACR register (Offset 0x00 for MM2S and 0x30 for S2MM) to set interrupt enables if desired, and set VDMACR.RS=1 to start the AXI VDMA channel running.
		//2. Write a valid video frame buffer start address to the channel START_ADDRESS register 1 to N where N equals Frame Buffers (Offset 0x5C up to 0x98 for MM2S and 0xAC up to 0xE8 for S2MM). Set the REG_INDEX register if required.
		//   When AXI VDMA is configured for an address space greater than 32, each start address is to be programmed as a combination of two registers where the first register is used to specify LSB 32 bits of address while the next register is used to specify MSB 32 bits.
		//3. Write a valid Frame Delay (valid only for Genlock Slave) and Stride to the channel FRMDLY_STRIDE register (Offset 0x58 for MM2S and 0xA8 for S2MM).
		//4. Write a valid Horizontal Size to the channel HSIZE register (Offset 0x54 for MM2S and 0xA4 for S2MM).
		//5. Write a valid Vertical Size to the channel VSIZE register (Offset 0x50 for MM2S and 0xA0 for S2MM). This starts the channel transferring video data.

		int get_version()
		{
			 return memRead32(VDMA_BASE | OFF_VDMA_VERSION) ;
		}

		void get_s2mm_status()
		{
			int status_reg;
			status_reg = memRead32(VDMA_BASE|OFF_VDMA_S2MM_STAT_REG);
			xil_printf("S2MM Status info : 0x%08x\n\r", status_reg );
		}

		void get_mm2s_status()
		{
			int status_reg;
			status_reg = memRead32(VDMA_BASE|OFF_VDMA_MM2S_STAT_REG);
			xil_printf("MM2S Status info : 0x%08x\n\r", status_reg );
		}

		void clear_s2mm_status()
		{
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_STAT_REG, 0xffffffff) ;
		}

		void clear_mm2s_status()
		{
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_STAT_REG, 0xffffffff) ;
		}

		void s2mm_reset()
		{
			print("Resetting S2MM...\n\r");
			memoryWrite32( VDMA_BASE|OFF_VDMA_S2MM_CTRL_REG, VDMA_CTRL_REG_RESET );			//issue reset
		}

		void mm2s_reset()
		{
			print("Resetting MM2S...\n\r");
			memoryWrite32( VDMA_BASE|OFF_VDMA_MM2S_CTRL_REG, VDMA_CTRL_REG_RESET );			//issue reset
		}

		void s2mm_initialise()
		{
			print("Initialising S2MM...\n\r");
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_CTRL_REG, VDMA_CTRL_REG_INT_GENLOCK |
									  VDMA_CTRL_REG_GENLOCK_ENABLE	 |
									  VDMA_CTRL_REG_CIRCULAR_PARK);							// Set up Config register
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_FRMDLY_STRIDE, HSIZE*3);	// Set Stride value		(0x780 * 3)
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_FRMBUFF1, HSIZE*VSIZE*3*1);				// Specify start address for frame buff 1 0xac to 0xe8 for s2mm
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_FRMBUFF2, HSIZE*VSIZE*3*2);				// Specify start address for frame buff 2
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_FRMBUFF3, HSIZE*VSIZE*3*3);				// Specify start address for frame buff 3
		}

		void s2mm_start_dma()
		{
			print("Starting S2MM DMA...\n\r");
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_CTRL_REG,
			    memRead32(VDMA_BASE|OFF_VDMA_S2MM_CTRL_REG) | VDMA_CTRL_REG_START);			// Put DMA in run mode
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_HSIZE, (HSIZE*3 & 0xffff));				// 1920 (0x780) Horizontal size definition (bytes) S2MM 0xa4
			memoryWrite32(VDMA_BASE|OFF_VDMA_S2MM_VSIZE, (VSIZE & 0x1fff));					// 1080 (0x438) Vertical size definition S2MM 0xa0..Starts DMA transfer
		}

		void mm2s_initialise()
		{
			print("Initialising MM2S...\n\r");
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_CTRL_REG, VDMA_CTRL_REG_INT_GENLOCK |
					VDMA_CTRL_REG_GENLOCK_ENABLE	 |
					  VDMA_CTRL_REG_CIRCULAR_PARK);								 								// Set up control register
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_FRMDLY_STRIDE, HSIZE*3 & 0xffff | 0x01000000); 				// Set Stride value
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_FRMBUFF1, HSIZE*VSIZE*3*1);				// Specify start address for frame buff 1 0x5c to 0x98 for mm2s
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_FRMBUFF2, HSIZE*VSIZE*3*2);				// Specify start address for frame buff 2
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_FRMBUFF3, HSIZE*VSIZE*3*3);				// Specify start address for frame buff 3
		}

		void mm2s_start_dma()
		{
			print("Starting MM2S DMA...\n\r");
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_CTRL_REG,
				memRead32(VDMA_BASE|OFF_VDMA_MM2S_CTRL_REG) | VDMA_CTRL_REG_START);			//Put DMA in run mode
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_HSIZE, HSIZE*3);							// 1980 (0x780) Horizontal size definition (bytes) MM2S offset 0x54)
			memoryWrite32(VDMA_BASE|OFF_VDMA_MM2S_VSIZE, VSIZE);												// 1080 (0x438) Vertical size definition MM2S offset 0x50)
		}

