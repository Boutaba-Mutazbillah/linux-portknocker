# Boutaba-PortKnocking-Daemon
A high-performance Port-Knocking Daemon written in pure C for Linux, featuring dynamic key-hashed network port sequencing to enforce stealth infrastructure firewalls.
# 🥷 Boutaba Port-Knocking Daemon (v1.1)

A lightweight, high-performance security daemon written in pure C, optimized for **Arch Linux** systems. It enforces a strict "stealth" network perimeter by tracking custom multi-staged connection sequences before exposing protected server ports.

## 🌀 Architectural Features

* **Dynamic Key-Hashed Sequencing:** Implements a deterministic port-generation algorithm based on a custom Secret Key, shifting target listen vectors across high-range dynamic ports to defeat standard automated port mapping scanners.
* **Low-Resource Socket Pipelining:** Uses standard POSIX socket handling routines (`socket`, `bind`, `listen`, `accept`) dynamically constructed block-by-block, ensuring an absolute minimum footprint on kernel system memory.
* **Firewall Hardening Logic:** Simulates automated access rules execution upon validating complete sequence parity, followed by an immediate state reset routine for persistent micro-perimeter isolation.

## 🛠️ Compilation

```bash
gcc -O3 main.c -o port_knock_daemon
```
