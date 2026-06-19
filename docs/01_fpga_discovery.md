# 01 - FPGA Discovery and Project Introduction

## Introduction

This project started as a personal journey to learn FPGA development and digital signal acquisition.

The main objective was to build a complete acquisition chain capable of converting an analog signal into digital data, processing it inside an FPGA, and visualizing the results on a computer.

The project was developed using affordable hardware modules that are widely available online.

---

## Objectives

The goals of this project were:

* Learn the FPGA development workflow
* Understand the Verilog hardware description language
* Configure and program a Spartan-6 FPGA
* Interface an external ADC with the FPGA
* Transfer acquired data to a computer
* Visualize data in real time using Python

---

## Hardware Selection

To keep the project accessible and low-cost, the following hardware was selected:

### FPGA Board

* Spartan-6 XC6SLX9 development board
* Purchased from AliExpress
* Integrated USB programming interface
* Integrated USB-UART interface
* SPI Flash memory for standalone boot

### ADC Module

* AD9248 ADC module
* 14-bit resolution
* Up to 65 MSPS sampling rate
* Parallel CMOS output

---

## Final System Goal

The target architecture of the project is shown below:

```text
Analog Signal
      │
      ▼
+-------------+
|   AD9248    |
+------+------+ 
       │
       ▼
+-------------+
| Spartan-6   |
|    FPGA     |
+------+------+ 
       │
       ▼
+-------------+
| USB-UART    |
+------+------+ 
       │
       ▼
+-------------+
|   Python    |
| Visualization|
+-------------+
```

The FPGA captures digital samples from the ADC and transmits selected samples to a computer through UART. A Python application receives and displays the acquired waveform in real time.

---

## Learning Roadmap

The project was divided into several development stages:

### Stage 1 – FPGA Discovery

* Install Xilinx ISE Design Suite
* Create a first FPGA project
* Understand the compilation flow

### Stage 2 – First Hardware Test

* Blink an LED
* Verify pin assignments
* Generate a bitstream

### Stage 3 – FPGA Programming

* Program the FPGA using iMPACT
* Store the design in SPI Flash
* Verify autonomous boot

### Stage 4 – UART Communication

* Implement a UART transmitter
* Send data to a computer
* Verify communication

### Stage 5 – ADC Integration

* Study the AD9248 operation
* Capture parallel data
* Validate acquisition

### Stage 6 – Data Visualization

* Receive UART data with Python
* Decode ADC samples
* Display real-time graphs

---

## Expected Outcome

At the end of the project, the system should be capable of:

* Acquiring analog signals
* Converting them into digital samples
* Processing data inside the FPGA
* Sending samples to a PC
* Displaying the waveform in real time

The following documents describe each development stage in detail.
