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

![FPGA Board](FPGA-ADC-AD9248-Acquisition-System/hardware/fpga_aliexpress.png)

### Resources

* FPGA: XC6SLX9
* Family: Spartan-6
* Development Software: Xilinx ISE Design Suite 14.7

Purchase link:

(https://fr.aliexpress.com/item/1005008389075810.html?spm=a2g0o.productlist.main.13.633c112fzdqvxX&algo_pvid=8f1b1beb-d48a-4f57-9c42-c98703847098&algo_exp_id=8f1b1beb-d48a-4f57-9c42-c98703847098-12&pdp_ext_f=%7B%22order%22%3A%2254%22%2C%22eval%22%3A%221%22%2C%22fromPage%22%3A%22search%22%7D&pdp_npi=6%40dis%21EUR%2121.19%2121.19%21%21%21160.17%21160.17%21%40211b441e17822058210078723ecf5a%2112000044820516115%21sea%21FR%210%21ABX%211%210%21n_tag%3A-29910%3Bd%3Aa2b2a83%3Bm03_new_user%3A-29895&curPageLogUid=wAorHI3Rjnfj&utparam-url=scene%3Asearch%7Cquery_from%3A%7Cx_object_id%3A1005008389075810%7C_p_origin_prod%3A)

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

![AD9248 Board](FPGA-ADC-AD9248-Acquisition-System/hardware/adc_aliexpress.png)

Purchase link:

[(Add board link)]https://fr.aliexpress.com/item/1005010066644896.html?src=google&src=google&albch=shopping&acnt=248-630-5778&isdl=y&slnk=&plac=&mtctp=&albbt=Google_7_shopping&aff_platform=google&aff_short_key=UneMJZVf&gclsrc=aw.ds&albagn=888888&ds_e_adid=&ds_e_matchtype=&ds_e_device=c&ds_e_network=x&ds_e_product_group_id=&ds_e_product_id=fr1005010066644896&ds_e_product_merchant_id=5318022646&ds_e_product_country=FR&ds_e_product_language=fr&ds_e_product_channel=online&ds_e_product_store_id=&ds_url_v=2&albcp=19000710609&albag=&isSmbAutoCall=false&needSmbHouyi=false&gad_source=1&gad_campaignid=17725339642&gbraid=0AAAAACWaBwfqFGN9ztgrbDvkt1rzGN2ly&gclid=CjwKCAjw3ejRBhAdEiwADkqPnyEKqiuYm-JFkeX5G6jdGJnsg4ial5c3OSBx9byDl1F_Vjfxvv3acBoCPxIQAvD_BwE

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
