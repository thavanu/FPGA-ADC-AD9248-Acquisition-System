# 04 - UART Communication

## Objective

After validating the FPGA hardware and learning how to store a design inside the SPI Flash memory, the next step was to establish communication between the FPGA and a computer.

This communication channel would later be used to transmit data acquired from the AD9248 ADC to a Python application running on a PC.

The development board already includes an onboard USB-UART converter, making UART a simple and practical choice for data transmission.

---

# Why UART?

UART (Universal Asynchronous Receiver Transmitter) is one of the simplest communication protocols to implement inside an FPGA.

Only one signal is required for transmission:

```text
FPGA TX
    ↓
USB-UART Converter
    ↓
Computer
```

The USB-UART converter on the board automatically creates a virtual COM port on the computer, allowing the FPGA to communicate directly with software running on the PC.

---

# Understanding UART Frames

A standard UART frame contains:

| Field     | Bits |
| --------- | ---- |
| Start Bit | 1    |
| Data Bits | 8    |
| Stop Bit  | 1    |

Total:

```text
10 bits per transmitted byte
```

The line remains at logic '1' while idle.

When a transmission starts:

```text
Idle → Start → Data → Stop
```

Example transmission of 0x55:

```text
1 | 0 | 10101010 | 1
```

---

# Generating the Baud Rate

The FPGA is clocked by the onboard oscillator:

```text
50 MHz
```

The UART module uses the following parameters:

```verilog
parameter CLK_FREQ  = 50000000;
parameter BAUD_RATE = 115200;
```

The baud-rate divider is calculated as:

```text
CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
```

```text
CLKS_PER_BIT = 50,000,000 / 115,200
```

```text
CLKS_PER_BIT = 434
```

This means each UART bit remains active for 434 FPGA clock cycles.

---

# Actual Baud Rate

Since the divider must be an integer value, the actual baud rate becomes:

```text
50,000,000 / 434
```

```text
115,207 baud
```

The resulting error is:

```text
(115207 - 115200) / 115200 × 100
```

```text
0.006%
```

This error is negligible and fully compatible with standard serial communication.

---

# UART Transmitter Implementation

A dedicated UART transmitter module was developed.

The module receives:

```text
clk
tx_start
data_in
```

and generates:

```text
tx
tx_busy
```

The transmission sequence is:

1. Wait for a transmission request.
2. Build a UART frame.
3. Send the start bit.
4. Send the 8 data bits.
5. Send the stop bit.
6. Return to idle state.

### UART Frame Generation

The frame is generated using:

```verilog
tx_shift <= {1'b1, data_in, 1'b0};
```

which creates:

```text
Stop Bit | Data[7:0] | Start Bit
```

The bits are then transmitted sequentially.

---

# Throughput Analysis

Understanding UART bandwidth is important because it directly limits how much ADC data can be sent to the computer.

At:

```text
115200 baud
```

and:

```text
10 bits per byte
```

the maximum throughput becomes:

```text
115200 / 10
```

```text
11520 bytes/s
```

or approximately:

```text
11.5 kB/s
```

---

# Preparing for ADC Data Transmission

The final goal of the UART interface was to transmit ADC samples.

The AD9248 produces:

```text
14-bit samples
```

To simplify synchronization on the Python side, a custom protocol was created.

Each sample is transmitted using three bytes:

```text
0xAB | ADC[13:6] | ADC[5:0]
```

Where:

* `0xAB` is a synchronization byte.
* `ADC[13:6]` contains the 8 most significant bits.
* `ADC[5:0]` contains the 6 least significant bits.

Total packet size:

```text
3 bytes per sample
```

---

# Maximum Sample Rate

Since the UART can transmit:

```text
11520 bytes/s
```

and each ADC sample requires:

```text
3 bytes
```

the maximum theoretical sample rate becomes:

```text
11520 / 3
```

```text
3840 samples/s
```

This is the maximum acquisition rate that can be transmitted through UART using the chosen protocol.

---

# Comparing UART and ADC Speeds

The ADC clock generated inside the FPGA operates at:

```text
1 MHz
```

This corresponds to:

```text
1,000,000 samples/s
```

However, the UART can only transmit:

```text
3840 samples/s
```

Comparison:

```text
1,000,000 / 3840
```

```text
≈ 260
```

The ADC acquires data approximately 260 times faster than the UART can transmit it.

This immediately reveals the main limitation of the system:

> The UART interface is the communication bottleneck.

---

# Limiting the Transmission Rate

To avoid overflowing the communication channel, only selected samples are transmitted.

A counter controls when a transmission occurs.

Example:

```verilog
if(counter == 499999)
```

Using a 50 MHz clock:

```text
50,000,000 / 500,000
```

```text
100 transmissions/s
```

Only 100 ADC samples per second are sent to the computer.

This is far below the UART limit and guarantees reliable communication.

---

# Verifying the Communication

Once implemented, the UART output was connected to the onboard USB-UART converter.

A serial terminal was used to verify reception:

* PuTTY
* Tera Term
* RealTerm

The transmitted bytes were successfully received on the computer.

This confirmed:

* Correct baud-rate generation.
* Correct UART frame structure.
* Reliable FPGA-to-PC communication.

---

# Result

The FPGA successfully transmitted data to the computer through the onboard USB-UART interface.

This validated:

✓ UART transmitter implementation

✓ Baud-rate generation

✓ Serial communication timing

✓ FPGA-to-PC communication

✓ ADC data framing protocol

✓ Throughput calculations

---

# What I Learned

This stage introduced several important concepts:

* UART protocol fundamentals
* Baud-rate generation
* Serial communication timing
* State machine design
* FPGA-to-PC communication
* Data framing and synchronization
* Communication bandwidth limitations

The UART interface would later become the main communication channel used to transfer AD9248 samples to a Python visualization application.

---

# Transition to Next Step

With reliable communication established between the FPGA and the computer, the next step was to interface the AD9248 ADC and begin capturing real analog signals.
