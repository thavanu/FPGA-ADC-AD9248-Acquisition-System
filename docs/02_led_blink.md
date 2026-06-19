# 02 - First Contact with the FPGA Board

## Starting Point

The FPGA development board used in this project was purchased from AliExpress.

Very little documentation was provided with the board, so before writing any code it was necessary to understand how the hardware was connected.

The first objective was simple:

> Make one onboard LED blink.

Although simple, this required identifying the FPGA device, the clock source and the LED connections.

---

# Identifying the FPGA

The first step was to inspect the FPGA package mounted on the board.

The marking on the chip was:

```text
XC6SLX9-2TQG144
```

This information was required when creating the Xilinx ISE project.

From this marking it was possible to determine:

* FPGA Family: Spartan-6
* Device: XC6SLX9
* Package: TQG144
* Speed Grade: -2


---

# Finding the Clock Source

An FPGA design requires a clock source.

The board contains an oscillator, but no documentation indicated which FPGA pin it was connected to.

The PCB traces were therefore inspected manually.

Following the oscillator output trace revealed that it was connected to FPGA pin 55.

The oscillator reference was then searched online and the datasheet indicated a frequency of:

```text
50 MHz
```

The frequency could also be verified using an oscilloscope.


At this point, the first two required signals were known:

```text
Clock Pin = 55
Clock Frequency = 50 MHz
```

---

# Finding the LEDs

The next step was to determine which FPGA pins controlled the onboard LEDs.

Again, the PCB traces were followed manually.

The following connections were identified:

```text
LED0 → Pin 56
LED1 → Pin 57
LED2 → Pin 58
LED3 → Pin 59
```


Now enough information was available to create a first FPGA design.

---

# Creating the Blink Design

A simple Verilog module was created.

The idea is straightforward:

* Count clock cycles.
* Toggle an LED after a delay.
* Repeat forever.

Since the FPGA clock runs at 50 MHz, a counter can be used to generate a visible blinking frequency.

### Verilog Source

```verilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Universite cote d'azur
// Engineer: 
// 
// Create Date:    20:27:56 05/19/2026 
// Design Name: 
// Module Name:    led_blink 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module led_blink(
    input clk,
    output led
);

reg [24:0] counter = 25'd0;

always @(posedge clk)
begin
    counter <= counter + 1'b1;
end

assign led = counter[24];

endmodule

```

---

# Creating the Constraints File

The FPGA now knows which signals exist, but it still does not know where they are connected physically.

A UCF file was therefore created.

### Clock

```text
NET "clk" LOC = "P55";
```

### LED

```text
NET "led" LOC = "P56";
```

### Complete UCF

```text
NET "led" LOC = P56;

NET "clk" LOC = P55;

```

---

# Building the Design

Once the source code and constraints file were ready, the design was compiled using Xilinx ISE.

The build flow was:

```text
Verilog Source
      ↓
Synthesize - XST
      ↓
Implement Design
      ↓
Generate Programming File
      ↓
.bit File
      ↓
Open iMPACT
      ↓
Program FPGA
```

The final result of this process is a `.bit` file that can be loaded into the FPGA.

---


# What I Learned

This first experiment introduced several important FPGA concepts:

* Reading FPGA package markings
* Reverse-engineering PCB connections
* Locating clock sources
* Understanding pin constraints
* Writing basic Verilog
* Generating a bitstream
* Programming a Spartan-6 FPGA

With this foundation established, the next step was learning how to permanently store a design inside the onboard SPI Flash memory.
