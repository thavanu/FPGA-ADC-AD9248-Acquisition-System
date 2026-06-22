# Python Real-Time ADC Visualization (Explanation of Implementation)

## Overview

This Python script is responsible for receiving ADC data from the FPGA over UART and visualizing it.

However, it is important to understand that this is not a true hardware real-time oscilloscope, but a software-based streaming visualization.

The system follows this pipeline:

Analog Signal → AD9248 ADC → FPGA → UART → Python → Plot

---

# Data Acquisition Principle

The FPGA sends ADC samples using the following frame format:

0xAB | ADC[13:6] | ADC[5:0]

The Python script continuously reads incoming UART bytes and reconstructs valid frames.

---

# Serial Buffer Handling

A global byte buffer is used to manage incoming data:

- Bytes are appended as they arrive from UART
- The script searches for the sync byte `0xAB`
- Once found, the next two bytes are used to reconstruct the sample

This method allows recovery from:
- Lost bytes
- Misalignment
- Noise on UART line

---

# ADC Reconstruction

The 14-bit ADC value is reconstructed using:

raw = (MSB << 6) | LSB

Then converted into voltage using:

V = (raw - 8192) * VREF / 8192

This assumes the AD9248 uses offset binary encoding.

---

# Visualization Method

The script uses matplotlib FuncAnimation to update the plot periodically.

Each update cycle performs:

1. Read available UART data
2. Decode valid samples
3. Append samples to buffer
4. Update plot window

---

# Real-Time Limitation

Even though the system appears real-time, it is limited by:

## UART bandwidth
- 115200 baud
- limited throughput (~1000 samples/s max in practice)

## Python processing
- single-thread execution
- blocking serial reads

## Matplotlib rendering
- not optimized for high-frequency updates
- GUI dependent refresh rate

---

# System Behavior

Due to these limitations:

- The plot is pseudo real-time
- Data may arrive in bursts
- Small latency is expected

This behavior is normal for Python-based visualization systems.

---

# Possible Improvements

To improve performance and achieve smoother real-time display:


- Implement circular buffer (ring buffer)
- Increase UART baud rate (e.g. 921600)
- Add FPGA FIFO buffering

---

# Conclusion

This implementation demonstrates:

✓ UART communication with FPGA  
✓ Frame synchronization using 0xAB  
✓ 14-bit ADC reconstruction  
✓ Real-time signal visualization (software-based)

However, it remains a software-limited real-time system rather than a true hardware oscilloscope.
