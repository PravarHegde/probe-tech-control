#!/bin/bash
# MK1 Agent Installation Script
# Called by Probe Tech Control Web UI

set -e

AGENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SERVICE_NAME="mk1-agent"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "Installing MK1 AI Agent..."

# 1. Create Python Virtual Environment
cd "$AGENT_DIR"
if [ ! -d "mk1-env" ]; then
    echo "Creating virtual environment..."
    python3 -m venv mk1-env
fi

# 2. Install Dependencies
echo "Installing dependencies..."
./mk1-env/bin/pip install -r requirements.txt

# 3. Create Systemd Service (Requires sudo from WebUI/user)
echo "Creating systemd service..."

cat <<EOF | sudo tee "$SERVICE_FILE"
[Unit]
Description=MK1 AI 3D Printing Agent
After=network.target moonraker.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$AGENT_DIR
ExecStart=$AGENT_DIR/mk1-env/bin/python $AGENT_DIR/mk1_agent.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd and starting MK1 Agent..."
sudo systemctl daemon-reload
sudo systemctl enable mk1-agent
sudo systemctl restart mk1-agent

echo "MK1 Agent Installation Complete!"
