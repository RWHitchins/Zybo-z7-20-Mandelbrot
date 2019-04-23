# Using the ZYBO Z7-20 as a Mandelbrot set generator

The goal of this project is to develop a 1080P zooming Mandelbrot set generator on the [Digilent Zybo Z7-20 board](https://reference.digilentinc.com/reference/programmable-logic/zybo-z7/start). FPGA logic will be used to perform the mandelbrot iteration. The [Xilinx](https://www.xilinx.com) Zynq ARM will be running bare-metal C (no OS) and will be used only for configuration and control/status. This is being developed because it's something I've always wanted to do. I am aware that modern software solutions to perform mandelbrot set 'live zooming' are very effective, but this is more of an exercise because it's there...!!

The mandelbrot iteration calculations will use fixed-point arithmetic (ieee_proposed.fixed_pkg) 

In the first stage of development the design will generate AXIS video 'on the fly' as the image data is calculated, and this will be fed through an AXI TPG to an AXI VDMA block where the image data is written to DDR. The AXI TPG provides the possibility of superimposing crosshairs to the video image if required.

A timing control (TC) block provides the timing signals to an AXI-stream to video output block which controls the reading of DDR data via the AXI VDMA block. Data from the AXI-stream to video block then drives an RGB2DVI block (courtesy of [Digilent](https://github.com/digilent)) which performs the [TMDS](https://en.wikipedia.org/wiki/Transition-minimized_differential_signaling) (Transition Minimised Differential Signaling) required for the HDMI output.

The initial architecture is more of a proof of concept and is not expected to be able to perform calculations quickly enough to create a smooth zooming effect. It certainly won't be able to keep up with modern software solutions running on microprocessors with clock speeds in the gigahertz region. Further development will consider alternative architectures with a view to speeding up the calculation (almost certainly by performing calculations in parallel)  

Please feel free to use any of this design for your own purposes if you think it might be useful!

This design uses Xilinx Vivado 2018.3. Before you do anything with the Zybo, you need to add the Digilent-specific board files.
Details on how to do this can be found [here](https://reference.digilentinc.com/vivado:boardfiles)

I have included the board files (current at the time of writing) in the folder "board_files"

Roger Hitchins (rwhitchins@gmail.com)
