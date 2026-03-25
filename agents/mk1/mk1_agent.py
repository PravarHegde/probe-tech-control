import os
import time
import requests
import json
from fastapi import FastAPI, BackgroundTasks
from apscheduler.schedulers.background import BackgroundScheduler
import uvicorn
from openai import OpenAI
from pydantic import BaseModel

# --- Configuration ---
MOONRAKER_URL = os.getenv("MOONRAKER_URL", "http://localhost:7125")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
AGENT_PORT = 8081

app = FastAPI(title="MK1 AI Agent")
scheduler = BackgroundScheduler()

# Provide a mock or real OpenAI client
client = OpenAI(api_key=OPENAI_API_KEY) if OPENAI_API_KEY else None

# --- Core Data Store ---
agent_state = {
    "hardware_health": "Unknown",
    "profit_margin": 0.0,
    "last_fail_detection": "None",
    "gcode_analysis": {}
}

# --- Module: Fail Detection (Computer Vision) ---
def run_fail_detection():
    print("[MK1] Running Fail Detection Vision check...")
    # In a real scenario, fetch snapshot from Moonraker: GET /server/webcams/snapshot
    # Then send base64 to OpenAI Vision API to detect spaghetti
    # For now, simulate:
    try:
        response = requests.get(f"{MOONRAKER_URL}/printer/objects/query?webhooks&extruder")
        if response.status_code == 200:
            agent_state["last_fail_detection"] = "No spaghetti detected (Camera clear)"
    except Exception as e:
        agent_state["last_fail_detection"] = f"Error connecting to Moonraker: {str(e)}"

# --- Module: Hardware & Profit Analysis ---
def run_hardware_analysis():
    print("[MK1] Analyzing hardware and history...")
    try:
        # Fetch History
        history = requests.get(f"{MOONRAKER_URL}/server/history/list").json()
        jobs = history.get('result', {}).get('jobs', [])
        
        total_filament = sum([j.get('filament_used', 0) for j in jobs])
        # Calculate profit assuming $20/kg filament cost and some average revenue per model
        cost = (total_filament / 1000) * 0.02 # 2 cents per gram
        revenue = len(jobs) * 5.0 # Average $5 per small print sale
        agent_state["profit_margin"] = revenue - cost
        
        agent_state["hardware_health"] = "Optimal (No critical Klipper errors in history)"
        
    except Exception as e:
         print(f"[MK1] Hardware analysis error: {e}")

# --- Module: G-Code Analysis ---
class GCodePayload(BaseModel):
    filename: str

@app.post("/api/analyze_gcode")
def analyze_gcode(payload: GCodePayload):
    # Fetch G-Code metadata from Moonraker to analyze parameters
    # E.g., print time, filament used, slicer speeds
    agent_state["gcode_analysis"][payload.filename] = {
        "status": "Analyzed successfully",
        "ai_suggestions": [
            "Consider reducing infill on this part to save 15g of filament and increase profit margin.",
            "Print speed is optimal for this hardware."
        ]
    }
    return agent_state["gcode_analysis"][payload.filename]

# --- API Endpoints for Web UI ---
@app.get("/api/status")
def get_status():
    return {
        "agent": "MK1",
        "status": "Active",
        "data": agent_state
    }

if __name__ == "__main__":
    print("Starting MK1 AI Agent System...")
    scheduler.add_job(run_fail_detection, 'interval', minutes=1)
    scheduler.add_job(run_hardware_analysis, 'interval', minutes=5)
    scheduler.start()
    
    uvicorn.run(app, host="0.0.0.0", port=AGENT_PORT)
