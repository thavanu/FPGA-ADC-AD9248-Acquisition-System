# First FPGA Test - LED Blink

## Objective

Verify that the FPGA board is operational and understand the complete Xilinx ISE workflow.

## Steps

1. Create a new ISE project.
2. Select the Spartan-6 XC6SLX9 device.
3. Create a Verilog module.
4. Assign FPGA pins using a UCF file.
5. Synthesize the design.
6. Generate the bitstream.
7. Program the FPGA.

## Verilog Code

```verilog
module blink(
    input clk,
    output reg led
);

always @(posedge clk)
    led <= ~led;

endmodule
