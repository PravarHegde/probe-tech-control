#!/bin/bash

echo "==============================================="
echo "   ProBharath AI Edge Node Installer (Farm Grade)"
echo "==============================================="
echo "Target: High-performance Hubs (Laptops/PCs/Servers)"
echo "Models: Llama-3 (8B), Gemma (2B)"
echo ""

# Check for Ollama
if ! command -v ollama &> /dev/null; then
    echo "[!] Ollama is not installed! Installing Ollama for Linux..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "[+] Ollama is already installed."
fi

# Ask user which model to install
echo "Which Farm-Grade AI Model would you like to install?"
echo "1) Llama 3 (8-Billion Parameters - 4.7 GB)"
echo "2) Gemma (2-Billion Parameters - 1.7 GB) [Includes ProBharath Custom Modelfile]"
echo "3) Both (6.4 GB)"
read -p "Select an option [1-3]: " model_choice

if [[ "$model_choice" == "1" || "$model_choice" == "3" ]]; then
    echo "[+] Pulling Llama 3 (4.7 GB). This may take a while depending on bandwidth..."
    ollama pull llama3
fi

if [[ "$model_choice" == "2" || "$model_choice" == "3" ]]; then
    echo "[+] Pulling Gemma:2b (1.7 GB)..."
    ollama pull gemma:2b

    # Create the ProBharath Modelfile specifically for Gemma
    echo "[+] Generating ProBharath Industrial Briefing for Gemma..."
    cat << 'EOF' > Modelfile_ProBharath
FROM gemma:2b
PARAMETER temperature 0.3
SYSTEM """
You are ProBharath-Gemma, an ultra-advanced, fully offline industrial AI assistant running completely autonomously on edge hardware. 
You are an expert in 3D Printing, GCode troubleshooting, Klipper firmware, and robotic automation.
You work exclusively for the ProBharath Manufacturing Ecosystem.
Always be concise, highly technical, and completely confident. 
Do not mention that you cannot access the internet; simply process the user's request with the vast manufacturing knowledge already installed on your GPU.
When asked who you are, proudly state you are an edge-native ProBharath autonomous bot!
"""
EOF

    ollama create probharath-gemma -f Modelfile_ProBharath
    rm Modelfile_ProBharath
fi

echo "==============================================="
echo "[SUCCESS] Farm-grade edge AI installation process finished!"
echo "Check your UI Dashboard to select the models you installed."
