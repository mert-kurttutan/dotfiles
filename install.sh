#!/bin/bash

# Check if Rust is installed
if command -v rustc &>/dev/null; then
    echo "Rust is already installed."
else
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    echo "Rust installation complete."
fi

set -e  # Exit immediately if a command exits with a non-zero status

# Define the installation path for uv
UV_BIN="$HOME/.local/bin/uv"

# Function to install uv
install_uv() {
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo "uv installation complete."
}

# Check if uv is installed
if command -v uv &>/dev/null; then
    echo "uv is already installed."
elif [ -f "$UV_BIN" ]; then
    echo "uv is installed in $UV_BIN"
else
    install_uv
fi

# ınstall important cli tools
cargo install macchina --version 6.4.0
