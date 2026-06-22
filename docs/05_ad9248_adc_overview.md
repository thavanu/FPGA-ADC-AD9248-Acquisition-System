# 05 - Discovering the AD9248 ADC

## Objective

With UART communication working correctly, the next step was to interface an Analog-to-Digital Converter (ADC) with the FPGA.

The ADC selected for this project is the AD9248, a high-speed 14-bit converter capable of sampling analog signals at rates up to 65 MSPS.

Before connecting the ADC to the FPGA, it was necessary to understand how the device operates and how data is transferred between the ADC and the FPGA.

---

# What is an ADC?

An Analog-to-Digital Converter (ADC) transforms a continuous analog voltage into a digital value.

The ADC periodically samples the input signal and assigns a binary value representing the measured voltage.

```text
Analog Signal
      ↓
    ADC
      ↓
Digital Samples
```

The FPGA can then process these digital samples.

---

# AD9248 Overview

The ADC module used in this project is based on the Analog Devices AD9248.

Main specifications:

| Parameter           | Value         |
| ------------------- | ------------- |
| Resolution          | 14 bits       |
| Maximum Sample Rate | 65 MSPS       |
| Input Type          | Differential  |
| Output Interface    | Parallel CMOS |
| Supply Voltage      | 3.3 V         |

The module was purchased from AliExpress and includes the AD9248 ADC along with the required support circuitry.

*Insert ADC module photo here.*

---

# Resolution

The AD9248 provides:

```text
14-bit resolution
```

This means the ADC can represent:

```text
2¹⁴ = 16384 levels
```

The output range extends from:

```text
0
```

to:

```text
16383
```

Each digital value corresponds to a specific analog input voltage.

---

# Differential Inputs

Unlike many low-speed ADCs, the AD9248 uses differential inputs.

The analog signal is applied between:

```text
VIN+
VIN-
```

instead of between a signal and ground.

```text
VIN+
   ↑
 Signal Difference
   ↓
VIN-
```

Differential inputs provide:

* Better noise immunity
* Improved signal integrity
* Higher dynamic range

This architecture is commonly used in high-speed data acquisition systems.

---

# Sampling Clock

The AD9248 requires an external sampling clock.

A conversion occurs on each clock edge.

```text
Clock Edge
     ↓
ADC Samples Input
     ↓
Digital Output Updated
```

For the first experiments, the clock was generated directly by the FPGA.

Using the 50 MHz onboard oscillator and a divider, an ADC clock of:

```text
1 MHz
```

was generated.

This means:

```text
1,000,000 samples/s
```

were acquired.

Although the AD9248 supports much higher rates, starting with a lower frequency simplifies debugging.

---

# Parallel Output Interface

Unlike SPI-based ADCs, the AD9248 provides all conversion bits simultaneously.

The output bus consists of:

```text
D13 ... D0
```

```text
D13 D12 D11 D10 D9 D8 D7 D6 D5 D4 D3 D2 D1 D0
```

Every clock cycle, the FPGA can read the complete conversion result.

This parallel interface is one of the reasons why high-speed ADCs are commonly paired with FPGAs.

---

# Connecting the ADC to the FPGA

The ADC module was connected directly to the Spartan-6 FPGA.

Signals used:

| Signal | Description        |
| ------ | ------------------ |
| ACL    | ADC Sampling Clock |
| D0-D13 | ADC Data Bus       |
| GND    | Ground             |
| 3.3V   | Power Supply       |

The FPGA generates the sampling clock and simultaneously captures the ADC output bus.

```text
FPGA
 │
 ├── ACL ─────► AD9248
 │
 ◄── D[13:0] ──
 │
 ▼
Sample Storage
```

---

# Capturing Samples

The ADC output bus is sampled on the rising edge of the generated ADC clock.

Example:

```verilog
always @(posedge clk_50m)
begin
    if (acl_rising)
        sample <= ADC_D;
end
```

Each captured sample is stored inside a register before being transmitted through UART.

This creates a stable snapshot of the ADC output.

---

# First Verification

Before connecting real analog signals, several verification methods can be used:

* Apply a fixed DC voltage
* Observe the digital value variation
* Check for stable readings
* Verify bit ordering

A constant input voltage should produce a nearly constant digital value.

This helps validate:

* ADC operation
* FPGA capture logic
* Pin assignments
* Clock generation

---

# Challenges Encountered

Several aspects required attention:

### Differential Inputs

The ADC expects a differential signal rather than a single-ended voltage.

### Timing

The FPGA must sample the output data at the correct moment relative to the ADC clock.

### Pin Mapping

All 14 data lines must be correctly assigned in the UCF constraints file.

An incorrect mapping immediately produces corrupted data.

---

# Hardware Limitation Encountered

The AD9248 is a dual-channel ADC and can simultaneously convert two independent analog inputs.

However, while analyzing the ADC module used in this project, an unexpected limitation was discovered.

Although both analog input channels are available on the board, only one digital output bus is routed to the external connector.

After inspecting the PCB traces, it became clear that the second channel data is not available at the module output.

Additionally, the AD9248 output multiplexer selection pin (SMUX) is permanently tied to ground on the module.

As a result, the output multiplexer is fixed and only one ADC channel can be accessed from the FPGA.

```text
Channel A ──► Output Bus ──► FPGA

Channel B ──► Not Routed

# Result

The FPGA successfully generated the ADC clock and captured the 14-bit output bus.

This validated:

✓ ADC clock generation

✓ FPGA-to-ADC interface

✓ Parallel data acquisition

✓ Sample storage

✓ Hardware connectivity

---

# What I Learned

This stage introduced several important concepts:

* ADC fundamentals
* Differential signal acquisition
* Sampling theory
* Parallel digital interfaces
* ADC clock generation
* FPGA data capture techniques

Understanding the AD9248 architecture was an essential step before building the complete acquisition chain.

---

# Transition to Next Step

With the ADC correctly interfaced and samples successfully captured, the next step is to transmit these samples through UART and visualize them in real time using Python.
