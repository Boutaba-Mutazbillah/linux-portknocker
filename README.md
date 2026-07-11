# Linux Port Knocking Daemon (PoC)

## Overview
This repository contains a lightweight, educational implementation of a **Port Knocking Daemon** for Linux environments. It simulates a stealth security layer that keeps critical management ports (like SSH Port 22) completely closed to network scanners, opening them dynamically only when a specific, pre-defined sequence of connection attempts ("knocks") is successfully verified.

## How it Works
The application operates as a background service (daemon) monitoring raw network sockets:
1. **Closed Perimeter:** By default, all incoming management ports are blocked via firewall rulesets.
2. **The Sequence:** The daemon listens for incoming packets on a cryptographic or static sequence of closed ports (e.g., Port `7000` -> `8000` -> `9000`).
3. **Dynamic Rule Injection:** Upon detecting the correct sequence within a specific time window, the daemon triggers a firewall modification (such as injecting an `iptables` or `nftables` rule) to temporarily whitelist the client's IP address.
4. **Auto-Timeout:** After a configured period, the temporary access rule expires, and the port returns to its stealth state.

## Core Concepts Covered
- Raw socket programming and network packet parsing in Linux.
- State-machine logic handling network sequences and execution timeouts.
- Dynamic interface interaction with system firewall tables.

## Disclaimer
This project is built strictly for educational purposes, low-level networking research, and systems security auditing. It serves as a proof-of-concept for high-availability access control mechanics.
