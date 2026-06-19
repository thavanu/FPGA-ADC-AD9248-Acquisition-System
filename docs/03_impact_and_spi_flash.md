# 03 - FPGA Programming and SPI Flash Configuration

## Objective

After successfully testing the FPGA with a simple LED design, the next step was to make the configuration persistent after power-off.

When a Spartan-6 FPGA is programmed through JTAG, the configuration is stored only in volatile memory. As soon as power is removed, the FPGA loses its configuration and must be programmed again.

The objective of this stage was to understand how the FPGA boots and how to store the design permanently inside the onboard SPI Flash memory.

---

# Understanding FPGA Configuration Modes

Unlike a microcontroller, a Spartan-6 FPGA does not contain internal non-volatile memory for storing a user design.

When powered on, the FPGA is initially empty and must load its configuration from an external source.

The Spartan-6 supports multiple configuration methods:

* JTAG programming (volatile)
* SPI Flash boot (non-volatile)

### Key Difference

| Method    | Persistence | Usage               |
| --------- | ----------- | ------------------- |
| JTAG      | Temporary   | Development / Debug |
| SPI Flash | Permanent   | Autonomous Boot     |

With JTAG programming, the bitstream is loaded directly into the FPGA.

With SPI Flash programming, the bitstream is stored in an external memory and automatically loaded every time the board powers up.

---

# Onboard SPI Flash Memory

The development board includes an external SPI Flash memory connected to the FPGA.

The first step was to identify the memory mounted on the board.

By reading the component marking, the following reference was found:

```text
W25Q16JVSIQ
```

This device is manufactured by Winbond and provides 16 Mbit of non-volatile storage.

### Role in the System

```text
Power On
    ↓
FPGA Starts
    ↓
Read SPI Flash
    ↓
Load Bitstream
    ↓
Run User Design
```

At power-up, the FPGA reads the bitstream stored inside the Flash memory and configures itself automatically.

---

# Generating the Bitstream

Before programming the SPI Flash, the FPGA design must first be compiled.

The LED test project developed previously was used for this experiment.

After synthesis and implementation, Xilinx ISE generated the FPGA configuration file:

```text
led_blink.bit
```

This file contains the complete hardware configuration of the FPGA.

---

# Using iMPACT Tool

The SPI Flash is programmed using the Xilinx iMPACT utility.

The FPGA board was connected through USB and the JTAG chain was detected successfully.

### Programming Flow

1. Open iMPACT
2. Detect the JTAG chain
3. Detect the FPGA
4. Add SPI Flash memory
5. Assign the generated bitstream
6. Generate a PROM file
7. Program the Flash memory

```text
.bit File
    ↓
iMPACT
    ↓
PROM File (.mcs)
    ↓
SPI Flash
    ↓
Automatic FPGA Boot
```


# Selecting the Flash Device

One interesting issue encountered during this step was that the exact Flash reference was not available in the iMPACT device list.

The board contains:

```text
W25Q16JVSIQ
```

However, iMPACT provides the following compatible option:

```text
W25Q16BV/CV
```

Since both devices share the same memory capacity and organization, this option was selected.

Programming completed successfully, confirming compatibility between the installed Flash memory and the selected device profile.


---

# Creating the PROM File

To store the design in Flash memory, the FPGA bitstream must first be converted into a PROM file.

This conversion is handled automatically by iMPACT.

The generated file is typically:

* `.mcs`


depending on the selected configuration.

This file is then written into the SPI Flash memory through JTAG.

---

# Programming the SPI Flash

Once the PROM file was generated, the Flash memory was programmed.

After programming:

* The FPGA no longer required manual JTAG loading.
* The design was stored permanently.
* The board became capable of autonomous startup.

The programming operation completed without errors.

---

# Boot Behavior Test

To verify correct operation, the board was completely powered off and then powered on again.

### Expected Behavior

* FPGA automatically reads the SPI Flash.
* FPGA loads the stored bitstream.
* User design starts immediately.

### Result

After power-up, the LED turned on automatically without opening iMPACT or reprogramming the FPGA.

This confirmed that:

✓ SPI Flash programming was successful

✓ FPGA boot mode was correctly configured

✓ Bitstream storage was permanent

✓ Automatic configuration was operational

---

# What I Learned

This stage introduced several important FPGA concepts:

* Difference between volatile and non-volatile configuration
* FPGA boot sequence
* External SPI Flash memories
* Bitstream generation
* PROM file creation
* iMPACT programming workflow
* Automatic FPGA startup

It also demonstrated how to identify components directly from a PCB and how to select a compatible device when the exact memory reference is not available in the programming software.

---

# Transition to Next Step

With SPI Flash programming working correctly, the FPGA was now capable of starting autonomously.

The next objective was to establish communication between the FPGA and a computer using UART, allowing data generated inside the FPGA to be transmitted and monitored externally.
