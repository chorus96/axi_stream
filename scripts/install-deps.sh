#!/usr/bin/env bash
# Install bender (hardware dependency manager) and verilator (SystemVerilog simulator)
set -euo pipefail

BENDER_VERSION="0.31.0"
VERILATOR_VERSION="5.020"

install_bender() {
    if command -v bender &>/dev/null; then
        echo "bender $(bender --version) already installed"
        return
    fi
    if command -v cargo &>/dev/null; then
        echo "Installing bender v${BENDER_VERSION} via cargo..."
        cargo install bender
    else
        echo "Error: cargo not found. Install Rust first: https://rustup.rs" >&2
        exit 1
    fi
}

install_verilator() {
    if command -v verilator &>/dev/null; then
        echo "$(verilator --version) already installed"
        return
    fi
    if command -v apt-get &>/dev/null; then
        echo "Installing verilator v${VERILATOR_VERSION} via apt-get..."
        apt-get install -y verilator
    else
        echo "Error: apt-get not found. Install verilator manually: https://verilator.org/guide/latest/install.html" >&2
        exit 1
    fi
}

install_bender
install_verilator

echo ""
echo "Installation complete:"
bender --version
verilator --version
