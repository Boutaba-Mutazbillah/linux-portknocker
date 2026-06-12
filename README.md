# 🥷 BPKD-Shield: Boutaba Port-Knocking Daemon (v1.1)

A high-performance, lightweight network security daemon written in pure C, optimized for **Arch Linux** and **BlackArch** subsystems. It enforces a strict "stealth" network perimeter by locking down all standard ports and tracking dynamic, multi-staged connection sequences before exposing protected server assets.

Developed independently for academic network defense evaluation and local firewall hardening research.

---

## 📝 Short Description
"A high-performance Port-Knocking Daemon written in pure C for Linux, featuring dynamic key-hashed network port sequencing to enforce stealth infrastructure firewalls."

---

## 🌀 Key Architectural Features

* **Dynamic Key-Hashed Sequencing:** Implements a deterministic port-generation routine based on a custom Secret Matrix Key. This algorithm dynamically shifts target listening vectors across high-range ports `(10000 + (hash * (i + 1)) % 40000)`, completely defeating automated port-scanning tools (like Nmap).
* **Low-Resource POSIX Socket Pipelining:** Built entirely upon core subsystem socket APIs (`socket`, `bind`, `listen`, `accept`). The daemon operates block-by-block, ensuring an absolute minimum volatile memory (RAM) and CPU footprint while running continuously as a background service.
* **Firewall Hardening Logic:** Features an isolated, state-machine processing loop. Upon verifying total sequence parity across all 3 connection milestones, it executes automated infrastructure rules (simulated gateway unlock) for a strict window of 10 seconds before a hard timeout triggers a zero-state matrix reset.

---

## 📖 Extended Technical Description

The **BPKD-Shield** addresses a fundamental flaw in network exposure management. In standard architectures, maintaining a live public interface (such as SSH on port 22) invites brute-force scripts and discovery sweeps. This utility introduces a cryptographic packet-sequence gatekeeper that keeps network paths invisible until a specific knock sequence is performed.

### 🔬 Core Algorithmic Mechanics:

1. **Deterministic Hashing Matrix:** The function `generate_dynamic_ports()` consumes a custom string vector, hashes its ascii bytes sequentially, and outputs an array of 3 unique, high-range port addresses. This ensures that the valid listening sequence remains completely hidden from standard dictionary maps.
2. **Network State Machine:** The daemon registers connection triggers synchronously. If an external entity sends a packet to the exact dynamic socket currently flagged by the `state` integer, the loop closes the socket, advances the index factor, and immediately binds to the next calculated port.
3. **Automated Perimeter Reset:** Upon processing all required sequence validation phases (`state == KNOCK_COUNT`), the engine initializes access privileges. After a 10-second operational window, an automatic session-clearing routine triggers, flushing local runtime values to prevent persistent micro-perimeter compromise.

---

## 🛠️ Compilation & Deployment

This utility compiles seamlessly on any Linux subsystem with standard development tools.

### 1. Compilation
Compile using the standard `gcc` compiler with optimization flags:
```bash
gcc -O3 main.c -o bpkd_shield
```

### 2. Execution
Run the daemon binary with administrative privileges to allow raw socket control:
```bash
sudo ./bpkd_shield
```

---

## 🔒 Responsible Disclosure & Usage Policy
This repository is published strictly for defensive, educational, and network-integrity validation purposes. The author does not provide automated remote exploit vectors or malicious scanning modules. All operations are designed to protect localized user infrastructure.
