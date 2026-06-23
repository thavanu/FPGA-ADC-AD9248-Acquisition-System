"""
adc_plot.py — Affichage des données ADC AD9248 depuis le Spartan-6
Protocole : 3 octets par sample → 0xAB | bits[13:6] | bits[5:0]<<2
Baud rate  : 115200
"""

import serial
import serial.tools.list_ports
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np
import sys
import time

# ── Configuration ──────────────────────────────────────────────────────────────
BAUD      = 115200
N_POINTS  = 100       # nombre de points affichés dans la fenêtre glissante
VREF      = 5.0       # tension de référence ADC en volts (à ajuster)
BITS      = 14        # résolution ADC

# ── Détection automatique du port série ────────────────────────────────────────
def find_port():
    ports = serial.tools.list_ports.comports()
    candidates = [p for p in ports if any(k in p.description.upper()
                  for k in ("USB", "UART", "CH340", "FTDI", "CP210", "STM"))]
    if candidates:
        return candidates[0].device
    if ports:
        return ports[0].device
    return None

port = find_port()
if port is None:
    print("Aucun port série détecté. Branchez votre adaptateur USB-UART.")
    sys.exit(1)
print(f"Port détecté : {port}")

# ── Connexion série ─────────────────────────────────────────────────────────────
try:
    ser = serial.Serial(port, BAUD, timeout=2)
    time.sleep(0.1)
    ser.reset_input_buffer()
    print(f"Connecté à {port} @ {BAUD} baud")
except serial.SerialException as e:
    print(f"Erreur ouverture port : {e}")
    sys.exit(1)

# ── Buffer des échantillons ─────────────────────────────────────────────────────
samples_raw  = []   # valeurs brutes 0–16383
samples_volt = []   # converties en volts

def raw_to_volt(raw):
    # AD9248 : binaire offset, 0x2000 (8192) = 0 V
    signed = raw - 8192          # recentre autour de 0
    return signed * VREF / 8192  # normalise sur ±Vref
# ── Décodage trame ──────────────────────────────────────────────────────────────
buf = bytearray()

def read_sample():
    """Lit un sample complet (3 octets) depuis le port série.
    Retourne la valeur brute 14 bits ou None si trame invalide."""
    global buf
    buf += ser.read(ser.in_waiting or 1)
    while len(buf) >= 3:
        # Cherche le marqueur 0xAB
        idx = buf.find(0xAB)
        if idx == -1:
            buf.clear()
            return None
        if idx > 0:
            buf = buf[idx:]   # resynchronisation
        if len(buf) < 3:
            return None
        b0, b1, b2 = buf[0], buf[1], buf[2]
        buf = buf[3:]
        if b0 != 0xAB:
            continue
        # Reconstruction : bits[13:6] dans b1, bits[5:0] dans b2[7:2]
        raw = (b1 << 6) | (b2 & 0x3F)
        return raw
    return None

# ── Mise en place du graphique ──────────────────────────────────────────────────
fig, axes = plt.subplots(2, 1, figsize=(10, 6))
fig.suptitle("ADC AD9248 — Canal A  |  Spartan-6", fontsize=13)

ax_raw  = axes[0]
ax_volt = axes[1]

ax_raw.set_title("Valeur brute (0 – 16383)")
ax_raw.set_ylim(-500, 16883)
ax_raw.set_xlim(0, N_POINTS - 1)
ax_raw.set_ylabel("Counts")
ax_raw.set_xlabel("Échantillons")
ax_raw.grid(True, alpha=0.3)

ax_volt.set_title(f"Tension estimée (Vref = ±{VREF} V)")
ax_volt.set_ylim(-VREF * 1.1, VREF * 1.1)
ax_volt.set_xlim(0, N_POINTS - 1)
ax_volt.set_ylabel("Volts")
ax_volt.set_xlabel("Échantillons")
ax_volt.axhline(0, color='gray', linewidth=0.8, linestyle='--')
ax_volt.grid(True, alpha=0.3)

line_raw,  = ax_raw.plot([], [], color='steelblue', linewidth=1.2)
line_volt, = ax_volt.plot([], [], color='darkorange', linewidth=1.2)

# Annotations temps réel
txt_raw  = ax_raw.text(0.02, 0.90, '', transform=ax_raw.transAxes,
                        fontsize=9, color='steelblue')
txt_volt = ax_volt.text(0.02, 0.90, '', transform=ax_volt.transAxes,
                         fontsize=9, color='darkorange')

plt.tight_layout()

# ── Animation ───────────────────────────────────────────────────────────────────
def update(_frame):
    for _ in range(20):
        raw = read_sample()
        if raw is not None:
            samples_raw.append(raw)
            samples_volt.append(raw_to_volt(raw))

    r = samples_raw[-N_POINTS:]
    v = samples_volt[-N_POINTS:]

    if not r:                                          # ← garde en premier
        return line_raw, line_volt, txt_raw, txt_volt

    if len(v) > 2:
        vmin, vmax = min(v), max(v)
        margin = max((vmax - vmin) * 0.1, 0.001)
        ax_volt.set_ylim(vmin - margin, vmax + margin)

    x = np.arange(len(r))
    line_raw.set_data(x, r)
    line_volt.set_data(x, v)

    txt_raw.set_text(f"min={min(r)}  max={max(r)}  moy={np.mean(r):.1f}")
    txt_volt.set_text(f"min={min(v)*1000:.1f} mV  max={max(v)*1000:.1f} mV  "
                      f"moy={np.mean(v)*1000:.1f} mV")

    return line_raw, line_volt, txt_raw, txt_volt
    
ani = animation.FuncAnimation(fig, update, interval=200, blit=False, cache_frame_data=False)

try:
    plt.show()
finally:
    ser.close()
    print("Port fermé.")