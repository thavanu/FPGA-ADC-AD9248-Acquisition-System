# 02 — What is an FPGA?

An **FPGA (Field-Programmable Gate Array)** is an integrated circuit
that can be configured by the user after manufacturing — hence
"field-programmable". Unlike a fixed-function chip, an FPGA contains
a large array of logic blocks that can be wired together in any
configuration to implement virtually any digital circuit.

In this project, the **Spartan-6 FPGA** acts as the digital backbone:
it generates the ADC sampling clock, captures 14-bit parallel data
at 1 MSPS, packs each sample into a UART frame, and streams everything
to the PC — all happening simultaneously in hardware.

---

## FPGA vs Microcontroller vs Processor

A common question: why use an FPGA instead of an Arduino, STM32, or
Raspberry Pi?

| Feature | Microcontroller | Processor (PC/RPi) | FPGA |
|---------|----------------|-------------------|------|
| Execution | Sequential | Sequential | Parallel |
| Clock speed | 8–480 MHz | 1–4 GHz | 50–500 MHz |
| Parallelism | None | Limited (cores) | Full — everything at once |
| Flexibility | Fixed peripherals | Fixed peripherals | Any peripheral |
| Programming | C / Python | C / Python | Verilog / VHDL |
| Development time | Fast | Fast | Slower |

**The key difference:** a microcontroller executes instructions one at
a time, sequentially. An FPGA implements hardware directly — every block
of logic runs **simultaneously**, every clock cycle.

### Why not just use an STM32 for this project?

Reading 14 bits via GPIO, packing into bytes, and sending UART all
in under 1 µs (1 MSPS) is not feasible on a microcontroller without
heavy DMA trickery.

On the Spartan-6, the ADC capture logic, the UART state machine, and
the clock generator all run **in parallel**. Adding more features costs
logic cells — not CPU time.

---

## What is Inside an FPGA?

An FPGA is made of several types of resources that can be connected
in any combination.

### Logic Cells (LUTs)

The basic building block. A LUT (Look-Up Table) is a small truth table
that can implement any combinational logic function:

```
4-input LUT:
  A, B, C, D ──► [16-entry truth table] ──► Output

Can implement: AND, OR, XOR, MUX, adder bit, comparator, etc.
```

### Flip-Flops (Registers)

Store a single bit of state, updated on every clock edge. Used for
counters, shift registers, state machines, and pipelines.

### Block RAM (BRAM)

Dedicated memory blocks for FIFOs, buffers, and data storage.

### DSP Blocks (DSP48A1)

Dedicated multiplier-accumulator blocks for high-speed arithmetic —
used in filters, FFTs, and the NCO/CORDIC in this project.

### I/O Blocks

Connect the internal logic to physical pins, with configurable voltage
standards (LVCMOS33, LVDS, etc.).

### Clock Management (DCM / PLL)

Dedicated clock resources for frequency multiplication, division, and
phase shifting — used to generate precise clocks from the onboard
oscillator.

**Spartan-6 XC6SLX9 resources:**

| Resource | Count |
|----------|-------|
| Logic cells | 5 720 |
| LUTs | 9 152 |
| Flip-flops | 11 440 |
| Block RAM | 576 Kbit |
| DSP48A1 | 16 |
| User I/O (TQG144) | 102 |
| DCM / PLL | 2 |

---

## How is an FPGA Programmed?

Unlike a microcontroller where you write C and compile to machine code,
an FPGA is programmed using a **Hardware Description Language (HDL)**.
In this project, that language is **Verilog**.

You do not write instructions that execute one after another.
You **describe hardware** — what logic exists and how it connects.

```verilog
// This describes a counter circuit that toggles an LED
always @(posedge clk) begin
    if (counter == 25_000_000 - 1) begin
        counter <= 0;
        led     <= ~led;
    end else begin
        counter <= counter + 1;
    end
end
```

The toolchain (Xilinx ISE 14.7) then synthesizes, maps, places, routes,
and generates a **bitstream** (.bit file) that configures the FPGA.

---

## The Development Flow

```
Verilog source (.v)
       │
       ▼
   Synthesis (XST)       HDL → netlist of gates
       │
       ▼
   Map + Place & Route   Gates → physical positions on chip
       │
       ▼
   Generate bitstream    .bit file
       │
       ▼
   iMPACT (JTAG)         Load onto FPGA
       │
       ▼
   Hardware running ✓
```

---

## FPGA Configuration — Volatile vs Non-Volatile

An FPGA's configuration is stored in SRAM — it is lost at power-off.

| Method | Persistence | Use case |
|--------|-------------|----------|
| **JTAG (iMPACT)** | Lost at power-off | Development and debugging |
| **SPI Flash** | Survives power-off | Standalone deployment |

When SPI Flash is programmed, the FPGA automatically reloads its
configuration at every power-up — no PC or JTAG needed.

---

## The Spartan-6 XC6SLX9 in This Project

The board is a low-cost Spartan-6 development board from AliExpress.

```
Chip marking: XC6SLX9-2TQG144
              │      │ │└── 144-pin QFP package
              │      │ └─── TQ = Thin Quad Flat Pack
              │      └───── Speed grade -2 (standard)
              └──────────── 9K logic cells
```

**Why Spartan-6 for this project:**
- Enough I/O to connect the 14-bit ADC data bus directly
- Enough logic for clock gen + capture + UART running in parallel
- Free toolchain — ISE WebPACK supports Spartan-6 with no license fee
- Low cost — ~$15–25 on AliExpress

**What the FPGA does in this project:**

```
┌─────────────────────────────────────────┐
│              Spartan-6 FPGA             │
│                                         │
│  ┌──────────┐    ┌──────────────────┐   │
│  │  Clock   │    │   ADC capture    │   │
│  │ divider  │───►│  14-bit latch    │   │
│  │ (50MHz→  │    └────────┬─────────┘   │
│  │  1MHz)   │             │             │
│  └──────────┘             ▼             │
│       │           ┌──────────────────┐  │
│       └──────────►│  UART TX         │  │
│  ACL out          │  3-byte framing  │  │
│                   └────────┬─────────┘  │
└────────────────────────────┼────────────┘
                             │ UART 115200
                             ▼
                          PC / Python
```

Everything in this diagram runs **simultaneously**, every clock cycle.

---

## Summary

| Parameter | Value |
|-----------|-------|
| FPGA family | Spartan-6 |
| Device | XC6SLX9 |
| Package | TQG144 |
| Logic cells | 5 720 |
| LUTs | 9 152 |
| Flip-flops | 11 440 |
| Block RAM | 576 Kbit |
| DSP blocks | 16 |
| User I/O | 102 |
| Onboard clock | 50 MHz |
| Toolchain | Xilinx ISE 14.7 WebPACK (free) |
| HDL | Verilog |

---

## Further Reading

- [Spartan-6 FPGA Family Datasheet](https://docs.amd.com/v/u/en-US/ds160)
- [Spartan-6 FPGA Packaging and Pinout](https://docs.amd.com/v/u/en-US/ug385)
- [Xilinx ISE WebPACK Download](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive-ise.html)

---

→ Next: [`03_verilog_basics.md`](03_verilog_basics.md) — Introduction to
Verilog HDL: how to describe hardware in code, the difference between
combinational and sequential logic, and the key constructs used in
this project.