import serial
import serial.tools.list_ports

# --- Config ---
BAUD = 115200

# Auto-détection du port
ports = list(serial.tools.list_ports.comports())
if not ports:
    print("Aucun port série détecté. Vérifiez le câble et le driver CH340.")
    exit()

print("Ports disponibles :")
for i, p in enumerate(ports):
    print(f"  [{i}] {p.device} — {p.description}")

idx = int(input("Choisir le port : "))
PORT = ports[idx].device

# --- Lecture ---
with serial.Serial(PORT, BAUD, timeout=2) as ser:
    print(f"\nConnecté sur {PORT} à {BAUD} baud. En attente de données...\n")
    while True:
        byte = ser.read(1)
        if byte:
            print(f"Reçu : {byte} | hex : {byte.hex().upper()} | ascii : {chr(byte[0]) if 32 <= byte[0] <= 126 else '.'}")