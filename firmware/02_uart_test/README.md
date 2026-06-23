# UART Test — Spartan-6 XC6SLX9

This sub-project validates the UART transmitter implemented on the Spartan-6 FPGA.
The FPGA sends data to the PC — this is the foundation of the ADC acquisition
pipeline where the FPGA will stream real-time samples for visualization.

---

## What you will learn

* How the UART protocol works at the bit level (start, data, stop)
* How to implement a UART transmitter in Verilog
* How to size registers correctly to avoid ISE synthesis warnings
* How to read serial data from the FPGA in Python
* How to use a serial terminal (PuTTY, minicom) to debug serial communication

---

## Why only TX — no RX?

In this project the FPGA only **sends** data to the PC — it does not need
to receive anything. The use case is one-directional: the FPGA streams
ADC samples and the PC visualizes them.

The Spartan-6 is perfectly capable of receiving UART data but it is not required for the acquisition
pipeline.

---

## Files

```
uart_test/
├── uart.v          ← Top module: sends ASCII 'A' every second
├── uart_tx.v       ← UART transmitter module (reusable)
├── uart.ucf        ← Pin constraints
└── uart_read.py    ← Python script to read and display received bytes
```

---

## How UART works

UART transmits one byte as a 10-bit frame at a fixed baud rate:

```
IDLE  START  D0  D1  D2  D3  D4  D5  D6  D7  STOP  IDLE
 1      0    b0  b1  b2  b3  b4  b5  b6  b7    1     1
```

* **IDLE** — line stays high when nothing is transmitted
* **START** — one bit low signals the beginning of a frame
* **D0–D7** — 8 data bits, LSB first
* **STOP** — one bit high ends the frame

Each bit lasts exactly `CLK_FREQ / BAUD_RATE` clock cycles.
At 50 MHz and 115200 baud that is **434 cycles per bit** (~8.68 µs).

---

## How it works

The top module instantiates `uart_tx` and sends the ASCII character
`'A'` (0x41) once per second using a 27-bit counter.

```
clk (50 MHz)
    │
    ▼
[27-bit counter]
    │ every 50 000 000 cycles (1 second)
    ▼
uart_tx ──► uart_tx pin ──► USB-UART adapter ──► PC
```

---

## Step by step

### 1 — Build and program the FPGA

1. Open **Xilinx ISE 14.7** → *File → New Project*
2. Device: `Spartan6` / `XC6SLX9` / `TQG144` / Speed `-2`
3. Add `uart.v`, `uart_tx.v`, `uart.ucf`
4. Set `uart` as the top module
5. Right-click `uart` → *Run All Implementation Steps*
6. Open iMPACT → *Boundary Scan → Initialize chain*
7. Assign `uart.bit` → *Program*

> ⚠️ **Driver required (Windows):** Install the CH340 driver before plugging
> the board: https://www.wch-ic.com/downloads/CH341SER_EXE.html

### 2 — Read the data in Python

```bash
pip install pyserial
python uart_read.py
```

The script auto-detects available serial ports and asks you to choose.
Expected output:

```
Connecté sur COM3 à 115200 baud. En attente de données...

Reçu : b'A' | hex : 41 | ascii : A
Reçu : b'A' | hex : 41 | ascii : A
Reçu : b'A' | hex : 41 | ascii : A
```

### 3 — Alternatively: use a serial terminal

**Windows (PuTTY):**
* Connection type: Serial / `COMx` / Speed: `115200` / 8N1

**Linux:**
```bash
screen /dev/ttyUSB0 115200
```

---

## Pin constraints

| Signal | FPGA pin | Description |
|--------|----------|-------------|
| clk | P55 | 50 MHz onboard oscillator |
| rst | P56 | Reset (active high) |
| uart_tx | P126 | UART TX → USB-UART adapter RX |

> ⚠️ Verify P126 against your board schematic before programming.

---

## Troubleshooting

**Python shows nothing / terminal blank**
→ Check the CH340 driver (Windows): https://www.wch-ic.com/downloads/CH341SER_EXE.html
→ Confirm the correct COM port in Device Manager
→ Verify UART TX pin idles at 3.3 V with a multimeter

**Garbage characters**
→ Baud rate mismatch — check `BAUD_RATE` in `uart_tx.v` matches Python/terminal (115200)
→ Wrong `CLK_FREQ` parameter — confirm oscillator is 50 MHz

**ISE synthesis warnings about tx_shift bits**
→ These are expected when sending a fixed character — ISE optimises constant bits.
→ They disappear when `data_in` is variable (as in the ADC project).

---

## Next step

In [`../adc_fpga/`](../03_adc_fpga/) the same `uart_tx` module is reused to stream
14-bit ADC samples to the PC at 115200 baud, decoded and visualized in real time
with Python.