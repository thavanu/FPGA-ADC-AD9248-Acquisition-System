# FPGA-Based Data Acquisition System

A complete FPGA data acquisition project based on a Xilinx Spartan-6 FPGA and an AD9248 14-bit Analog-to-Digital Converter.

The objective of this project is to demonstrate how to build a complete acquisition chain, from an analog signal to real-time visualization on a computer.

The project covers:

* FPGA development using Verilog HDL
* ADC interfacing
* UART communication
* SPI Flash programming
* Python-based visualization
* Hardware and software integration

## System Overview

The acquisition pipeline is illustrated below:

```text
Analog Signal
      │
      ▼
 AD9248 ADC
      │
      ▼
 Spartan-6 FPGA
      │
      ▼
 UART Communication
      │
      ▼
 Python Visualization
```

The FPGA captures samples from the ADC, formats the data into UART packets, and transmits them to a computer where a Python application displays the signal in real time.

---

# Hardware

## Spartan-6 FPGA Development Board

The project is based on a low-cost Spartan-6 development board featuring:

* Xilinx XC6SLX9 FPGA
* 50 MHz onboard oscillator
* USB-UART interface
* SPI Flash memory
* JTAG programming support

### FPGA Board

![FPGA Board](images/hardware/fpga_aliexpress.jpg)

### Resources

* FPGA: XC6SLX9
* Family: Spartan-6
* Development Software: Xilinx ISE Design Suite 14.7

Purchase link:

(Add board link)

---

## AD9248 ADC Module

The acquisition front-end is based on the AD9248.

Main characteristics:

* 14-bit resolution
* Dual-channel architecture
* Parallel digital outputs
* High-speed sampling capability

For this project, only one ADC channel is used.

### ADC Board

![AD9248 Board](images/hardware/adc_board.jpg)

Purchase link:

(Add board link)

---

## Hardware Setup

The AD9248 board is connected directly to the Spartan-6 FPGA.

### FPGA ↔ ADC Wiring

![FPGA ADC Wiring](images/hardware/fpga_adc_wiring.jpg)

The FPGA generates the sampling clock, captures the 14-bit ADC output bus, and sends the acquired data to the PC through the onboard USB-UART interface.

---

# Features

* Verilog FPGA development
* ADC clock generation
* AD9248 data acquisition
* UART communication
* SPI Flash boot configuration
* Python real-time visualization
* Complete educational documentation

---

# Project Goals

This repository is intended both as a working FPGA project and as an educational resource.

By following the documentation, readers will learn how to:

* Configure a Spartan-6 FPGA
* Create Verilog designs
* Interface a parallel ADC
* Implement UART communication
* Program SPI Flash memory
* Transfer data to a computer
* Visualize signals using Python
