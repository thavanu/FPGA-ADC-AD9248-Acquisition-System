### Prerequisites — Xilinx ISE 14.7

ISE 14.7 is the last version of the Xilinx ISE toolchain (2013).
It does not run reliably on Windows 10/11 or recent Linux distributions.
**The recommended approach is to run ISE inside a Virtual Machine.**

**Recommended setup:**
- **VM software:** VirtualBox (free) or VMware
- **Guest OS:** Ubuntu 14.04 LTS or CentOS 6 (both officially supported by ISE)
- **ISE edition:** WebPACK (free, no license required for Spartan-6 XC6SLX9)

**Download ISE 14.7:**
https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html

> ⚠️ The installer is large (~6 GB). During installation select **WebPACK**
> and make sure **Spartan6** is checked in the device list.

> ⚠️ **USB passthrough:** To use iMPACT from inside the VM, you must pass
> through the JTAG USB device to the guest OS.
> In VirtualBox: *Devices → USB → select the JTAG adapter*
> In VMware: the USB device appears automatically when plugged in.


# LED Blink — Spartan-6 XC6SLX9

This is the first sub-project of the acquisition system.
The goal is simple: blink an LED at 1 Hz to validate the entire toolchain
from Verilog code to physical hardware.

If the LED blinks, everything works: ISE synthesis, UCF constraints,
bitstream generation, and JTAG programming via iMPACT.

---

## What you will learn

* How to identify an FPGA from its package marking
* How to find the clock pin by tracing PCB copper
* How to write a clock divider in Verilog
* How to write a UCF pin-constraint file
* How to synthesize and implement a design in Xilinx ISE 14.7
* How to program the FPGA via JTAG with iMPACT

---

## Files

```
led_blink/
├── led_blink.v     ← Verilog top module: clock divider + LED toggle
└── led_blink.ucf   ← Pin constraints: clock and LED pin assignments
```

---

## How it works

The FPGA receives a 50 MHz clock from the onboard oscillator.
A 25-bit counter increments every clock cycle. When it reaches
25 000 000 (half a second), it resets and toggles the LED output.
The result is a 1 Hz blink visible to the naked eye.

```
clk (50 MHz)
    │
    ▼
[25-bit counter]
    │ every 25 000 000 cycles (0.5 s)
    ▼
toggle LED
    │
    ▼
LED blinks at 1 Hz
```

---

## Step by step

### 1 — Identify the FPGA

Read the marking on the chip:

```
XC6SLX9-2TQG144
```

| Field | Value | Meaning |
|-------|-------|---------|
| XC6SLX9 | Device | Spartan-6, 9K logic cells |
| -2 | Speed grade | Standard speed |
| TQG144 | Package | 144-pin QFP |

These four values are required when creating the ISE project.

### 2 — Find the clock pin

Trace the PCB copper from the onboard oscillator output to the FPGA.
On this board the oscillator connects to **pin P55** at **50 MHz**.

> Verify with an oscilloscope or multimeter in AC mode if unsure.

### 3 — Find the LED pin

Trace the PCB copper from one of the onboard LEDs back to the FPGA.
On this board:

```
LED0 → P119
```

> If your board differs, adjust the UCF file accordingly.

### 4 — Create an ISE project

1. Open **Xilinx ISE 14.7** → *File → New Project*
2. Fill in the device settings:

| Field | Value |
|-------|-------|
| Family | Spartan6 |
| Device | XC6SLX9 |
| Package | TQG144 |
| Speed | -2 |

3. Add `led_blink.v` and `led_blink.ucf` to the project
4. Set `led_blink` as the top module

### 5 — Synthesize and implement

Right-click `led_blink` in the Hierarchy panel →
*Run All Implementation Steps*

Wait for green ticks on all steps:
- ✓ Synthesize
- ✓ Translate
- ✓ Map
- ✓ Place & Route
- ✓ Generate Programming File

### 6 — Program via iMPACT

1. Double-click *Generate Programming File* → iMPACT opens
2. *Boundary Scan → Initialize chain*
3. The XC6SLX9 should appear in the chain
4. Right-click the device → *Assign New Configuration File*
5. Select `led_blink.bit`
6. Right-click → *Program*
7. The LED should start blinking at 1 Hz

> ⚠️ **iMPACT does not detect the FPGA?**
> Try a different USB cable — some cables are power-only with no data lines.
> Check that the JTAG driver is installed (on Windows, it installs automatically
> with ISE 14.7 via the **Digilent** or **Platform Cable USB** driver).
---

## Pin constraints

| Signal | FPGA pin | Description |
|--------|----------|-------------|
| clk | P55 | 50 MHz onboard oscillator |
| led | P119 | Onboard LED |

---

## Troubleshooting

**iMPACT does not detect the FPGA**
→ Check that ISE 14.7 is fully installed — the JTAG driver installs with it
→ Try a different USB cable — some cables are power-only with no data lines
→ On Windows, check Device Manager: the JTAG adapter should appear under "USB devices"
**All implementation steps pass but LED does not blink**
→ Check the LED pin in the UCF file — trace the PCB to confirm
→ Verify the oscillator is running (measure P55 with an oscilloscope)

**ISE reports "top module not found"**
→ Make sure the module name in `led_blink.v` matches exactly: `led_blink`
→ Right-click the `.v` file in ISE → *Set as Top Module*

---

## Next step

Once the LED blinks, the toolchain is validated.
Move on to [`../uart_test/`](../02_uart_test/) to implement UART communication
and send data from the FPGA to the PC.