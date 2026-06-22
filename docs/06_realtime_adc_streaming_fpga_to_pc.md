# 06 - ADC Acquisition Pipeline (FPGA → UART → PC)

## Objective

After validating both the AD9248 ADC interface and UART communication, the goal of this stage was to build a complete real-time acquisition chain.

This means connecting all previously developed blocks into a single working system:

- ADC sampling on FPGA
- Data capture and buffering
- UART transmission
- PC-side reception (Python)

Final data flow:

Analog Signal → AD9248 ADC → FPGA → UART → PC (Python)

---

# System Overview

The FPGA is responsible for all real-time processing:

AD9248 ADC → 14-bit parallel data → FPGA → framed packets → UART → USB-UART → Python

---

# ADC Clock Generation

The ADC requires an external sampling clock.

The FPGA generates this clock from the onboard 50 MHz oscillator:

50 MHz system clock → divider → ~1 MHz ADC clock

Each rising edge triggers a conversion sample.

---

# ADC Data Capture

The AD9248 outputs a 14-bit parallel data bus:

ADC_D[13:0]

The FPGA samples this bus on each rising edge:

always @(posedge clk_50m) begin
    if (acl_rising)
        sample <= ADC_D;
end

A register stores a stable snapshot before transmission.

---

# Data Framing

To synchronize data on the PC side, a simple protocol is used:

0xAB | ADC[13:6] | ADC[5:0]

Each sample = 3 bytes:

- 0xAB → frame header
- ADC[13:6] → MSB
- ADC[5:0] → LSB

This allows resynchronization if bytes are lost.

---

# UART Transmission

A state machine sends:

1. Header (0xAB)
2. MSB
3. LSB
4. Wait for tx_busy

---

# Baud Rate Configuration

UART is configured at:

115200 baud

Each frame:

10 bits (start + 8 data + stop)

Throughput:

115200 / 10 = 11520 bytes/s

Although 115200 is not the maximum possible baud rate, it was chosen for stability and debugging simplicity.

---

# Maximum Sampling Rate

Each ADC sample = 3 bytes:

11520 / 3 = 3840 samples/s

---

# System Limitation

ADC capability ≈ 1,000,000 samples/s  
UART capability ≈ 3,840 samples/s  

→ UART is the bottleneck (~260× slower)

---

# Rate Control Strategy

To avoid overflow, a counter reduces transmission rate:

if(counter == 499999)

50 MHz / 500000 = 100 transmissions/s

---

# FPGA Responsibilities

- ADC clock generation
- ADC data capture (14-bit)
- Buffering
- Packet formatting
- UART transmission control

---

# Result

✓ ADC sampling  
✓ FPGA acquisition  
✓ UART streaming  
✓ Frame synchronization  
✓ PC reception ready  

---

# What I Learned

- Real-time FPGA data pipelines
- UART timing and limitations
- ADC interfacing
- Data framing techniques
- Hardware/software co-design

---

# Next Step

Python visualization:

- Serial parsing
- 0xAB sync detection
- 14-bit reconstruction
- Real-time plotting7
