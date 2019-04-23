/*
 * tclib.h
 *
 *  Created on: 11 Feb 2019
 *      Author: RWHitchins
 */

#ifndef SRC_TCLIB_H_
#define SRC_TCLIB_H_

#define TC_CTRL								0x00
#define TC_STATUS							0x04
#define TC_ERROR							0x08
#define TC_VERSION							0x10
#define TC_GEN_HSIZE						0x70
#define TC_GEN_VSIZE						0x74

#define TC_CTRL_SW_ENABLE					0x00000001
#define TC_CTRL_REG_UPDATE					0x00000002
#define TC_CTRL_GEN_ENABLE					0x00000004
#define TC_CTRL_DET_ENABLE					0x00000008
#define TC_CTRL_SYNC_ENABLE					0x00000020
#define TC_CTRL_FRM_HSIZE_SRC				0x00000100
#define TC_CTRL_ACTV_HSIZE_SRC				0x00000200
#define TC_CTRL_HSYNC_START_SRC				0x00000400
#define TC_CTRL_HSYNC_END_SRC				0x00000800
#define TC_CTRL_FRM_VSIZE_SRC				0x00002000
#define TC_CTRL_ACTV_VSIZE_SRC				0x00004000
#define TC_CTRL_VSYNC_START_SRC				0x00008000
#define TC_CTRL_VSYNC_END_SRC				0x00010000
#define TC_CTRL_VBLANK_HOFF_SRC				0x00020000
#define TC_CTRL_CHROMA_SRC					0x00040000
#define TC_CTRL_VBLANK_POL_SRC				0x00100000
#define TC_CTRL_HBLANK_POL_SRC				0x00200000
#define TC_CTRL_VSYNC_POL_SRC				0x00400000
#define TC_CTRL_HSYNC_POL_SRC				0x00800000
#define TC_CTRL_ACTV_VID_POL_SRC			0x01000000
#define TC_CTRL_ACTV_CHROMA_POL_SRC			0x02000000
#define TC_CTRL_FIELD_ID_POL_SRC			0x04000000
#define TC_CTRL_FSYNC_RESET					0x40000000
#define TC_CTRL_SW_RESET					0x80000000


void get_tc_version();
void tc_start();
void get_tc_stats();

#endif /* SRC_TCLIB_H_ */
