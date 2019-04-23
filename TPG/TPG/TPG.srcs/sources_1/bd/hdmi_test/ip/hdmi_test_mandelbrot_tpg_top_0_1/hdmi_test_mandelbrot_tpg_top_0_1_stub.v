// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Wed Mar 20 09:15:18 2019
// Host        : LAPTOP-30C9QH2J running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Mandelbrot/TPG/TPG/TPG.srcs/sources_1/bd/hdmi_test/ip/hdmi_test_mandelbrot_tpg_top_0_1/hdmi_test_mandelbrot_tpg_top_0_1_stub.v
// Design      : hdmi_test_mandelbrot_tpg_top_0_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "mandelbrot_tpg_top,Vivado 2018.3" *)
module hdmi_test_mandelbrot_tpg_top_0_1(reset, clk, m0_axis_tready, m0_axis_tdata, 
  m0_axis_tvalid, m0_axis_tuser, m0_axis_tlast, m0_axis_tkeep, S_AXI_ACLK, S_AXI_ARESETN, 
  S_AXI_AWADDR, S_AXI_AWVALID, S_AXI_AWREADY, S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WVALID, 
  S_AXI_WREADY, S_AXI_BRESP, S_AXI_BVALID, S_AXI_BREADY, S_AXI_ARADDR, S_AXI_ARVALID, 
  S_AXI_ARREADY, S_AXI_RDATA, S_AXI_RRESP, S_AXI_RVALID, S_AXI_RREADY, eol, sof)
/* synthesis syn_black_box black_box_pad_pin="reset,clk,m0_axis_tready,m0_axis_tdata[23:0],m0_axis_tvalid,m0_axis_tuser[0:0],m0_axis_tlast,m0_axis_tkeep[2:0],S_AXI_ACLK,S_AXI_ARESETN,S_AXI_AWADDR[31:0],S_AXI_AWVALID,S_AXI_AWREADY,S_AXI_WDATA[31:0],S_AXI_WSTRB[3:0],S_AXI_WVALID,S_AXI_WREADY,S_AXI_BRESP[1:0],S_AXI_BVALID,S_AXI_BREADY,S_AXI_ARADDR[31:0],S_AXI_ARVALID,S_AXI_ARREADY,S_AXI_RDATA[31:0],S_AXI_RRESP[1:0],S_AXI_RVALID,S_AXI_RREADY,eol,sof" */;
  input reset;
  input clk;
  input m0_axis_tready;
  output [23:0]m0_axis_tdata;
  output m0_axis_tvalid;
  output [0:0]m0_axis_tuser;
  output m0_axis_tlast;
  output [2:0]m0_axis_tkeep;
  input S_AXI_ACLK;
  input S_AXI_ARESETN;
  input [31:0]S_AXI_AWADDR;
  input S_AXI_AWVALID;
  output S_AXI_AWREADY;
  input [31:0]S_AXI_WDATA;
  input [3:0]S_AXI_WSTRB;
  input S_AXI_WVALID;
  output S_AXI_WREADY;
  output [1:0]S_AXI_BRESP;
  output S_AXI_BVALID;
  input S_AXI_BREADY;
  input [31:0]S_AXI_ARADDR;
  input S_AXI_ARVALID;
  output S_AXI_ARREADY;
  output [31:0]S_AXI_RDATA;
  output [1:0]S_AXI_RRESP;
  output S_AXI_RVALID;
  input S_AXI_RREADY;
  output eol;
  output sof;
endmodule
