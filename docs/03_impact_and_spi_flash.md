# 03 - FPGA Programming and SPI Flash Configuration

## Objective

After successfully blinking an LED using JTAG programming, the next step was to make the FPGA design **persistent after power-off**.

By default, the bitstream is loaded into the FPGA via JTAG and is lost when the board is powered down.

The objective of this stage was to understand and use the **SPI Flash memory** on the board to store the design permanently.

---

# Understanding FPGA Configuration Modes

The Spartan-6 FPGA supports multiple configuration methods:

* JTAG programming (volatile)
* SPI Flash boot (non-volatile)

### Key Difference

| Method    | Persistence | Usage               |
| --------- | ----------- | ------------------- |
| JTAG      | Temporary   | Debug / Development |
| SPI Flash | Permanent   | Autonomous boot     |

---

# Onboard SPI Flash Memory

The development board includes an external SPI Flash memory connected to the FPGA.

This memory is used to store the bitstream that is loaded automatically at power-up.

### Role in the system

```text id="spi1"
SPI Flash
    ↓
FPGA Configuration Logic
    ↓
FPGA Starts Running Design
```

At power-on, the FPGA reads the bitstream from the flash and configures itself automatically.

---

# Generating the Bitstream

Before programming the SPI Flash, the FPGA design must first be compiled into a `.bit` file.

This step was already validated during the LED blink project.

No changes were required to the Verilog design at this stage.

---

# Using iMPACT Tool

The SPI Flash is programmed using the Xilinx iMPACT tool.

### Programming Flow

1. Open iMPACT
2. Detect JTAG chain
3. Identify FPGA and SPI Flash device
4. Assign `.bit` file
5. Convert to `.mcs` or PROM file
6. Program SPI Flash memory

```text id="flow1"
.bit file → iMPACT → .mcs file → SPI Flash → FPGA boot
```

---

# Creating the PROM File

To store the design in flash memory, the bitstream must be converted into a PROM format.

This allows the SPI Flash to understand the configuration data.

The generated file is typically:

* `.mcs`
* or `.bin` depending on configuration

---

# Programming the SPI Flash

Once the file is generated, it is written into the SPI Flash memory through JTAG.

After programming:

* The FPGA no longer requires manual JTAG loading
* The design is stored permanently
* The board can boot autonomously

---

# Boot Behavior Test

After SPI Flash programming, the board was power-cycled.

### Expected behavior:

* FPGA should automatically configure itself
* LED blink design should start immediately

### Result:

The LED started blinking without using iMPACT.

This confirmed that:

✓ SPI Flash programming was successful
✓ FPGA boot mode is correctly configured
✓ Design is stored permanently


# What I Learned

This stage introduced important FPGA concepts:

* Difference between volatile and non-volatile configuration
* FPGA boot sequence
* SPI Flash memory role
* Bitstream conversion process
* iMPACT programming workflow
* Autonomous FPGA boot behavior

---

# Transition to Next Step

With SPI Flash working, the FPGA can now boot independently.

The next step is to move from simple LED logic to **data communication between FPGA and a computer**, starting with UART transmission.
