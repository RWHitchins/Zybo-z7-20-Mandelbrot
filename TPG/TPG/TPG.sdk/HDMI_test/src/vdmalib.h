/*
 * vdmalib.h
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_VDMALIB_H_
#define SRC_VDMALIB_H_


#define OFF_VDMA_PARK_PTR_REG               0x28
#define OFF_VDMA_VERSION                    0x2c

#define OFF_VDMA_MM2S_CTRL_REG       		0x00
#define OFF_VDMA_MM2S_STAT_REG        		0x04
#define OFF_VDMA_MM2S_VSIZE                 0x50
#define OFF_VDMA_MM2S_HSIZE                 0x54
#define OFF_VDMA_MM2S_FRMDLY_STRIDE         0x58
#define OFF_VDMA_MM2S_FRMBUFF1           	0x5c
#define OFF_VDMA_MM2S_FRMBUFF2           	0x60
#define OFF_VDMA_MM2S_FRMBUFF3           	0x64
#define OFF_VDMA_MM2S_FRMBUFF4           	0x68

#define OFF_VDMA_S2MM_CTRL_REG       		0x30
#define OFF_VDMA_S2MM_STAT_REG        		0x34
#define OFF_VDMA_S2MM_IRQ_MASK              0x3c
#define OFF_VDMA_S2MM_REG_INDEX             0x44
#define OFF_VDMA_S2MM_VSIZE                 0xa0
#define OFF_VDMA_S2MM_HSIZE                 0xa4
#define OFF_VDMA_S2MM_FRMDLY_STRIDE         0xa8
#define OFF_VDMA_S2MM_FRMBUFF1           	0xac
#define OFF_VDMA_S2MM_FRMBUFF2           	0xb0
#define OFF_VDMA_S2MM_FRMBUFF3           	0xb4
#define OFF_VDMA_S2MM_FRMBUFF4           	0xb8

/* S2MM and MM2S control register flags */
#define VDMA_CTRL_REG_START                     0x00000001
#define VDMA_CTRL_REG_CIRCULAR_PARK             0x00000002
#define VDMA_CTRL_REG_RESET                     0x00000004
#define VDMA_CTRL_REG_GENLOCK_ENABLE            0x00000008
#define VDMA_CTRL_REG_FrameCntEn                0x00000010
#define VDMA_CTRL_REG_INT_GENLOCK          		0x00000080
#define VDMA_CTRL_REG_WrPntr                    0x00000f00
#define VDMA_CTRL_REG_FrmCtn_IrqEn              0x00001000
#define VDMA_CTRL_REG_DlyCnt_IrqEn              0x00002000
#define VDMA_CTRL_REG_ERR_IrqEn                 0x00004000
#define VDMA_CTRL_REG_Repeat_En                 0x00008000
#define VDMA_CTRL_REG_InterruptFrameCount       0x00ff0000
#define VDMA_CTRL_REG_IRQDelayCount             0xff000000

int get_version();
void get_s2mm_status();
void get_mm2s_status();
void clear_s2mm_status();
void clear_mm2s_status();
void s2mm_reset();
void mm2s_reset();
void s2mm_initialise();
void s2mm_start_dma();
void mm2s_initialise();
void mm2s_start_dma();


#endif /* SRC_VDMALIB_H_ */
