#!/bin/bash

echo "==============================================="
echo "   ProBharath AI Edge Node Installer (Pi Grade)"
echo "==============================================="
echo "Target: Low-power Hubs (Raspberry Pi 4/5, Android/Termux)"
echo "Models: TinyLlama (1.1B) - ~600MB RAM footprint"
echo ""

# Check for Ollama
if ! command -v ollama &> /dev/null; then
    echo "[!] Ollama is not installed!"
    echo "    - If on Raspberry Pi (Linux): Run 'curl -fsSL https://ollama.com/install.sh | sh'"
    echo "    - If on Android: Install Termux, install proot-distro, run 'proot-distro login ubuntu' and then install Ollama."
    echo "Please install Ollama first and rerun this script."
    exit 1
else
    echo "[+] Ollama is detected!"
fi

# Ask user which micro-model to install
echo "Which Pi-Grade Edge AI Model would you like to install?"
echo "1) TinyLlama (1.1B Parameters - ~650 MB RAM) [Includes ProBharath Custom Modelfile]"
echo "2) Qwen 2 (0.5B Parameters - ~350 MB RAM) [For extremely low-spec Androids]"
echo "3) Both"
read -p "Select an option [1-3]: " pi_model_choice

if [[ "$pi_model_choice" == "1" || "$pi_model_choice" == "3" ]]; then
    # Pull the lightweight model
    echo "[+] Pulling TinyLlama (637 MB). Highly compressed for Raspberry Pi CPUs..."
    ollama pull tinyllama

    # Create the ProBharath Lite Modelfile
    echo "[+] Generating ProBharath (Pi Edition) Briefing for TinyLlama..."
    cat << 'EOF' > Modelfile_ProBharath_Lite
FROM tinyllama
PARAMETER temperature 0.3
PARAMETER num_ctx 2048
SYSTEM """
You are ProBharath-Edge, an extremely lightweight autonomous AI running on embedded hardware (Raspberry Pi/Android) for the ProBharath Manufacturing Ecosystem.
You are an expert in 3D Printing and Klipper diagnostics. Be extremely brief, do not ramble, to save processing power.
"""
EOF

    ollama create probharath-lite -f Modelfile_ProBharath_Lite
    rm Modelfile_ProBharath_Lite
fi

if [[ "$pi_model_choice" == "2" || "$pi_model_choice" == "3" ]]; then
    echo "[+] Pulling Qwen 2 (0.5B). Ultra-micro model for 1GB RAM limits..."
    ollama pull qwen2:0.5b
fi

echo "==============================================="
echo "[SUCCESS] Pi-grade edge AI installation process finished!"
echo "Check your UI Dashboard to select the optimized micro-models."
