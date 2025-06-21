#!/bin/bash

# QR Code Generator Dependencies Installation Script
# This script installs the required Python packages for the QR code generator

set -e  # Exit on any error

echo "Installing QR Code Generator Dependencies..."
echo "============================================"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed or not in PATH"
    exit 1
fi

# Check if pip is available
if ! command -v pip3 &> /dev/null; then
    echo "Error: pip3 is not installed or not in PATH"
    exit 1
fi

echo "Python version: $(python3 --version)"
echo "Pip version: $(pip3 --version)"
echo ""

# Install required packages
echo "Installing qrcode[pil] (includes PIL/Pillow support)..."
pip3 install qrcode[pil]

echo "Installing Pillow (if not already installed)..."
pip3 install Pillow

echo ""
echo "✓ Dependencies installed successfully!"
echo ""
echo "You can now use the QR code generator:"
echo "  python3 qry/scripts/qr_generator.py --size-guide"
echo "  python3 qry/scripts/qr_generator.py 'https://example.com' --size 300"
echo ""
echo "To make the script executable everywhere, you can also run:"
echo "  chmod +x qry/scripts/qr_generator.py"
