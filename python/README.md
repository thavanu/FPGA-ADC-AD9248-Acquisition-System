# Python Visualization

This directory contains the Python scripts used to receive and display ADC samples transmitted by the FPGA through UART.

## Purpose

The FPGA captures samples from the AD9248 ADC and sends them to the computer using the onboard USB-UART interface.

The Python application:

* Opens the serial port
* Receives ADC samples
* Converts received bytes into numerical values
* Displays the signal in real time

---

# Directory Structure

```text id="xg1ezs"
python/

├── adc_plot.py
├── uart_capture.py
├── requirements.txt
└── README.md
```

---

# Requirements

Install the required packages:

```bash
pip install -r requirements.txt
```

or manually:

```bash
pip install pyserial numpy matplotlib
```

---

# Serial Communication

The FPGA sends ADC data through UART.

Example settings:

| Parameter | Value  |
| --------- | ------ |
| Baud Rate | 115200 |
| Data Bits | 8      |
| Stop Bits | 1      |
| Parity    | None   |

Modify these parameters in the Python script if necessary.

---

# Running the Program

```bash
python adc_plot.py
```

The program will:

1. Open the serial port.
2. Receive FPGA data.
3. Convert the received bytes.
4. Display the waveform.

---

# Data Flow

```text id="12cgvv"
AD9248
   │
   ▼
FPGA
   │
   ▼
UART
   │
   ▼
Python
   │
   ▼
Real-Time Plot
```

---

# Example Reception Code

```python
import serial

ser = serial.Serial('COM3', 115200)

while True:
    data = ser.read()
```

---

# Example Visualization

```python
import matplotlib.pyplot as plt
```

The received samples are continuously updated on a graph to visualize the ADC input signal.

---

# Expected Results

The application can display:

* DC levels
* Sine waves
* Square waves
* Noise measurements
* Other analog signals connected to the ADC input

---

# Future Improvements

* Automatic serial port detection
* Binary packet decoding
* Data logging to CSV
* FFT analysis
* Trigger functionality
* Oscilloscope-style interface
* PyQt graphical user interface

---

# Notes

The UART bandwidth is significantly lower than the ADC sampling rate.

As a result, only a subset of captured samples can be transmitted to the computer in real time.

This project demonstrates the complete acquisition chain:

```text id="mknv52"
Analog Signal
      │
      ▼
 AD9248
      │
      ▼
 Spartan-6 FPGA
      │
      ▼
 USB-UART
      │
      ▼
 Python Visualization
```
