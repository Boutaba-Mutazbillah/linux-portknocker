# Linux Port Knocking Daemon (PoC)

##  Overview
This repository contains a simple, direct Proof-of-Concept (PoC) of a **Port Knocking Daemon** written in **100% pure x86_64 Assembly (NASM)** for Linux. It runs as a stealth network layer that keeps ports (like SSH Port 22) closed, opening them only when a specific sequence of connection attempts ("knocks") is verified.

---

##  How it Works
The program opens a raw socket to capture incoming network packets and passes them through a simple state machine.

### Step-by-Step Flow:
1. **Stealth State:** All target ports are completely closed and dropped by default firewall rules.
2. **Packet Capturing:** The daemon listens on a raw socket to audit incoming connection attempts (e.g., Syn packets on Port `7000` -> `8000` -> `9000`).
3. **Sequence Verification:** A basic state machine tracks the source IP and the order of the port knocks within a strict time window.
4. **Dynamic Firewall Rule:** Once the correct sequence is verified, the daemon triggers a system call to execute a firewall command (like `iptables` or `nftables`) to whitelist the sender's IP.
5. **Timeout:** After a set period, the rule is removed, and the perimeter returns to a stealth state.

---

##  Compilation and Build (Makefile)
The build process is automated using a minimal `Makefile` without relying on external libraries.

### Build and Run Instructions
```bash
# Compile and link the assembler code automatically
make

# Run the network daemon natively (Requires root privileges for raw sockets)
sudo ./port_knocker

# Clean build artifacts
make clean
```

---

##  Project Structure (Makefile Code)
This is the `Makefile` used to compile the assembly source file natively:

```makefile
ASM=nasm
ASMFLAGS=-f elf64
LD=ld

all: port_knocker

port_knocker: main.o
	\$(LD) main.o -o port_knocker

main.o: main.asm
	\$(ASM) \$(ASMFLAGS) main.asm -o main.o

clean:
	rm -f *.o port_knocker
```
