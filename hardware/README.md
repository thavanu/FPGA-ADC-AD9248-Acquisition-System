# Hardware

This project is based on a low-cost FPGA development board and an AD9248 ADC module.

## Hardware Overview

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
| (On Board)  |
+------+------+ 
       │
       ▼
+-------------+
| Python Plot |
+-------------+
```

---

# FPGA Development Board
![fpga](fpga_aliexpress.png)

## Description

The FPGA used in this project is a Spartan-6 XC6SLX9 development board purchased from AliExpress.

### Main Features

* Xilinx Spartan-6 XC6SLX9
* On-board SPI Flash
* On-board JTAG programmer
* On-board USB-UART converter
* 50 MHz oscillator
* GPIO expansion headers

### Purpose in the Project

The FPGA performs:

* ADC sample acquisition
* Data processing
* UART transmission to the PC

### Development Tools

* Xilinx ISE Design Suite 14.7
* iMPACT

---

# AD9248 ADC Module
![adc](adc_aliexpress.png)
## Description

The ADC used in this project is based on the AD9248.

### Main Features

* 14-bit resolution
* Up to 65 MSPS
* Differential analog input
* Parallel digital output

### Purpose in the Project

The AD9248 converts the analog signal into digital samples which are captured by the FPGA.

### FPGA Interface

```text
ADC_CLK
ADC_D[13:0]
```

### Data Flow

```text
Analog Signal
      │
      ▼
 AD9248 ADC
      │
      ▼
  FPGA Capture
      │
      ▼
 UART Stream
      │
      ▼
 Python Plot
```

---

# Host Computer

## Software

The computer receives samples through the FPGA board's integrated USB-UART interface.

### Tools Used

* Python
* PySerial
* NumPy
* Matplotlib

---

# Future Hardware Improvements

Future versions of the project may include:

* Si5351 programmable clock generator
* STM32-based clock configuration
* Faster communication interfaces
* FPGA DSP processing
* FFT implementation
