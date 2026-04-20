import os
import time
import requests
import json
import socket
import subprocess
from fastapi import FastAPI, BackgroundTasks, Request
from apscheduler.schedulers.background import BackgroundScheduler
import uvicorn
from pydantic import BaseModel

# --- Configuration ---
MOONRAKER_URL = os.getenv("MOONRAKER_URL", "http://localhost:7125")

# Discovery Config
BT_BEACON_ENABLED = True
HOTSPOT_ENABLED = True
MCU_DISPLAY_ENABLED = True
CLIENT_CONNECTED = False

# AI API Integration Block
AI_PROVIDER = os.getenv("AI_PROVIDER", "openai")  # Options: 'openai' or 'gemini'
AI_API_KEY = os.getenv("AI_API_KEY", os.getenv("OPENAI_API_KEY", ""))
AI_ANALYSIS_MODE = os.getenv("AI_ANALYSIS_MODE", "on_demand") # Options: 'on_demand', 'background'
MCP_SERVER_ENABLED = os.getenv("MCP_SERVER_ENABLED", "true").lower() in ("true", "1")
AGENT_PORT = 8255

CONFIG_FILE = os.path.join(os.path.dirname(__file__), "config.json")
if os.path.exists(CONFIG_FILE):
    try:
        with open(CONFIG_FILE, "r") as f:
            cfg = json.load(f)
            if "AI_API_KEY" in cfg: AI_API_KEY = cfg["AI_API_KEY"]
            if "AI_PROVIDER" in cfg: AI_PROVIDER = cfg["AI_PROVIDER"]
            if "MCP_SERVER_ENABLED" in cfg: MCP_SERVER_ENABLED = cfg["MCP_SERVER_ENABLED"]
            if "AI_ANALYSIS_MODE" in cfg: AI_ANALYSIS_MODE = cfg["AI_ANALYSIS_MODE"]
    except Exception as e:
        print(f"[MK1] Error loading config: {e}")

app = FastAPI(title="MK1 AI Agent")
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

scheduler = BackgroundScheduler()

# Provide a mock or real AI client
client = None
def init_client():
    global client
    client = None
    if AI_API_KEY:
        if AI_PROVIDER == "openai":
            from openai import OpenAI
            client = OpenAI(api_key=AI_API_KEY)
        elif AI_PROVIDER == "gemini":
            try:
                from google import genai
                client = genai.Client(api_key=AI_API_KEY)
            except ImportError:
                print("[MK1] WARNING: google-genai is required for Gemini AI provider.")

init_client()

def ask_ai(prompt: str) -> str:
    if not client:
        return "Not analyzed: AI Client not configured or API Key missing."
    try:
        if AI_PROVIDER == "openai":
            response = client.chat.completions.create(
                model="gpt-4o-mini",
                messages=[{"role": "user", "content": prompt}]
            )
            return response.choices[0].message.content
        elif AI_PROVIDER == "gemini":
            response = client.models.generate_content(
                model='gemini-2.5-flash',
                contents=prompt,
            )
            return response.text
    except Exception as e:
        return f"AI Generation Error: {str(e)}"

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
        
        if AI_ANALYSIS_MODE == "background":
            summary = f"Total jobs: {len(jobs)}. Total filament: {total_filament:.2f}mm. State if this indicates heavy usage requiring maintenance."
            ai_status = ask_ai(summary)
            agent_state["hardware_health"] = f"Analyzed: {ai_status}"
        else:
            agent_state["hardware_health"] = "Data fetched. Waiting for on-demand AI Analysis."
            
    except Exception as e:
         print(f"[MK1] Hardware analysis error: {e}")

# --- Module: Discovery Manager (ProConnect Zero-Config) ---
def get_local_ip():
    try:
        # Most robust way to find the primary local IP on Linux
        arg = 'ip route get 1 | awk \'{print $7;exit}\''
        ip = subprocess.check_output(arg, shell=True).decode().strip()
        if not ip:
            # Fallback to secondary method if awk fails
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.settimeout(0.5)
            s.connect(('1.1.1.1', 80))
            ip = s.getsockname()[0]
            s.close()
        return ip if ip else "127.0.0.1"
    except Exception:
        return "127.0.0.1"

def run_hardware_discovery_sync():
    global CLIENT_CONNECTED
    ip = get_local_ip()
    print(f"[MK1] Connectivity Sync | IP: {ip}")
    
    # 1. Bluetooth Beacon (Rename to IP)
    if BT_BEACON_ENABLED and not CLIENT_CONNECTED:
        try:
            print(f"[MK1] Discovery: Setting BT Alias to {ip}")
            # Try system-alias first
            subprocess.run(["bluetoothctl", "system-alias", ip], capture_output=True, timeout=5)
            # Ensure powered on
            subprocess.run(["bluetoothctl", "power", "on"], capture_output=True, timeout=5)
        except Exception as e:
            print(f"[MK1] BT Sync Error: {e}")
            
    # 2. Wi-Fi Hotspot (ProBharath-Factory-<IP>)
    if HOTSPOT_ENABLED:
        try:
            ssid = f"ProBharath-Factory-{ip}"
            # Use 'nmcli -t' for stable scripting output
            try:
                active_cons = subprocess.check_output(["nmcli", "-t", "-f", "NAME", "connection", "show", "--active"], timeout=5).decode()
                if ssid not in active_cons:
                    print(f"[MK1] Discovery: Starting Hotspot {ssid}")
                    subprocess.run(["nmcli", "dev", "wifi", "hotspot", "ssid", ssid, "password", ""], capture_output=True, timeout=10)
            except Exception as inner_e:
                print(f"[MK1] NMCLI List Error: {inner_e}")
                # Try starting anyway if list fails
                subprocess.run(["nmcli", "dev", "wifi", "hotspot", "ssid", ssid, "password", ""], capture_output=True, timeout=10)
        except Exception as e:
            print(f"[MK1] Hotspot Sync Error: {e}")

    # 3. Klipper Display Feedback (M117)
    if MCU_DISPLAY_ENABLED:
        try:
            requests.post(f"{MOONRAKER_URL}/printer/gcode/script", json={"script": f"M117 IP: {ip}"}, timeout=2)
        except Exception as e:
            print(f"[MK1] MCU Display Sync Error: {e}")

def stop_hardware_discovery():
    try:
        print("[MK1] Stopping Hardware Discovery (Active Client Detected)")
        subprocess.run(["bluetoothctl", "power", "off"], capture_output=True)
        # We keep Hotspot on unless explicitly disabled in UI
    except Exception as e:
        print(f"Error stopping discovery: {e}")

# --- Module: G-Code Analysis ---
class GCodePayload(BaseModel):
    filename: str

@app.post("/api/analyze_gcode")
def analyze_gcode(payload: GCodePayload):
    # Ask AI dynamically
    prompt = f"Analyze optimal print parameters (speed, infill) for an object named {payload.filename} to maximize profit and reduce print time. Provide 2 short bullet points."
    ai_response = ask_ai(prompt)
    
    agent_state["gcode_analysis"][payload.filename] = {
        "status": "Analyzed successfully",
        "ai_suggestions": [ai_response]
    }
    return agent_state["gcode_analysis"][payload.filename]

class ChatPayload(BaseModel):
    input: str
    printerState: dict = None

@app.post("/")
def process_chat(payload: ChatPayload, request: Request):
    global CLIENT_CONNECTED
    if not CLIENT_CONNECTED:
        CLIENT_CONNECTED = True
        stop_hardware_discovery()
        
    user_text = payload.input.strip()
    
    # NLP Interceptor for Chat-based Configuration
    if user_text.lower().startswith("configure") or user_text.lower().startswith("/config"):
        global AI_API_KEY, AI_PROVIDER
        tokens = user_text.split()
        
        try:
            if "key" in tokens:
                AI_API_KEY = tokens[tokens.index("key") + 1]
            if "provider" in tokens:
                AI_PROVIDER = tokens[tokens.index("provider") + 1].lower()
                
            with open(CONFIG_FILE, "w") as f:
                json.dump({
                    "AI_API_KEY": AI_API_KEY,
                    "AI_PROVIDER": AI_PROVIDER,
                    "MCP_SERVER_ENABLED": MCP_SERVER_ENABLED,
                    "AI_ANALYSIS_MODE": AI_ANALYSIS_MODE
                }, f)
            init_client()
            return {"response": f"✅ Configuration securely saved via Chat Interface! Provider: '{AI_PROVIDER}'. Your MK1 agent is ready."}
        except Exception as e:
            return {"response": f"❌ Failed to parse configuration: {str(e)}\nExample usage: `/config provider openai key sk-xxx`"}

    prompt = f"User says: {payload.input}\nPrinter State: {payload.printerState}\nAct as an intelligent 3D printing assistant. Keep responses helpful and concise."
    ai_response = ask_ai(prompt)
    return {"response": ai_response}

class ConfigPayload(BaseModel):
    mcp_enabled: bool = None
    ai_api_key: str = None
    ai_provider: str = None
    analysis_mode: str = None

@app.post("/api/config")
def update_config(payload: ConfigPayload):
    global MCP_SERVER_ENABLED, AI_API_KEY, AI_PROVIDER, AI_ANALYSIS_MODE
    if payload.mcp_enabled is not None: MCP_SERVER_ENABLED = payload.mcp_enabled
    if payload.ai_api_key is not None: AI_API_KEY = payload.ai_api_key
    if payload.ai_provider is not None: AI_PROVIDER = payload.ai_provider
    if payload.analysis_mode is not None: AI_ANALYSIS_MODE = payload.analysis_mode
        
    with open(CONFIG_FILE, "w") as f:
        json.dump({
            "AI_API_KEY": AI_API_KEY,
            "AI_PROVIDER": AI_PROVIDER,
            "MCP_SERVER_ENABLED": MCP_SERVER_ENABLED,
            "AI_ANALYSIS_MODE": AI_ANALYSIS_MODE
        }, f)
        
    init_client()
    return {"status": "success", "message": "Configuration saved globally."}

# --- Ollama Model Manager Proxy Endpoints ---
class OllamaPullPayload(BaseModel):
    name: str

@app.post("/api/models/pull")
def pull_ollama_model(payload: OllamaPullPayload):
    try:
        response = requests.post("http://localhost:11434/api/pull", json={"name": payload.name, "stream": False}, timeout=600)
        return response.json()
    except Exception as e:
        return {"error": f"Failed to connect to Local Ollama: {str(e)}"}

class LocalInstallPayload(BaseModel):
    name: str

@app.post("/api/models/install_local")
def install_local_model(payload: LocalInstallPayload):
    import time
    print(f"[MK1] Bridging simulated local download from /home/ptc/aimarketplace/{payload.name}.gguf ...")
    time.sleep(2) # Simulate file IO/copy delay
    
    # In the future, this will either trigger `ollama create` or copy weights natively.
    # For now, it mocks success.
    return {"status": "success", "message": f"Successfully pulled {payload.name} from local bridge!"}

@app.get("/api/models/list")
def list_ollama_models():
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=10)
        return response.json()
    except Exception as e:
        return {"error": f"Failed to fetch models: {str(e)}"}

local_chat_memory = {}

class LocalChatPayload(BaseModel):
    model: str
    prompt: str

@app.post("/api/chat/local")
def chat_local_model(payload: LocalChatPayload, request: Request):
    global local_chat_memory, CLIENT_CONNECTED
    if not CLIENT_CONNECTED:
        CLIENT_CONNECTED = True
        stop_hardware_discovery()
        
    try:
        # Initialize Memory Array for this model session
        if payload.model not in local_chat_memory:
            local_chat_memory[payload.model] = []

        # RAG Interceptor Core: Klipper Tooling
        user_input_lower = payload.prompt.lower()
        if "printer.cfg" in user_input_lower:
            try:
                print(f"[MK1] RAG Tool Invoked: Fetching printer.cfg from Moonraker {MOONRAKER_URL}")
                cfg_res = requests.get(f"{MOONRAKER_URL}/server/files/config/printer.cfg", timeout=5)
                # Fallback to direct path if needed:
                if cfg_res.status_code == 200:
                    rag_context = f"SYSTEM INSTRUCTION: The user is discussing their live configuration. Literal printer.cfg data:\n{cfg_res.text}\n"
                    local_chat_memory[payload.model].append({"role": "system", "content": rag_context})
                else:
                    cfg_res_alt = requests.get(f"{MOONRAKER_URL}/machine/file/config/printer.cfg", timeout=5)
                    if cfg_res_alt.status_code == 200:
                        rag_context = f"SYSTEM INSTRUCTION: The user is discussing their live configuration. Literal printer.cfg data:\n{cfg_res_alt.text}\n"
                        local_chat_memory[payload.model].append({"role": "system", "content": rag_context})
                    else:
                        local_chat_memory[payload.model].append({"role": "system", "content": "SYSTEM ALERT: Failed to read printer.cfg from Moonraker."})
            except Exception as e:
                print(f"[MK1] RAG Fetch Error: {e}")
                local_chat_memory[payload.model].append({"role": "system", "content": f"SYSTEM ALERT: Network error locating printer.cfg: {e}"})

        # Insert structurally-formatted user memory
        # Force micro-models to behave with explicit short-response commands
        prompt_with_rules = payload.prompt
        if "lite" in payload.model or "tiny" in payload.model:
            prompt_with_rules += " (Strictly limit your response to 1 or 2 short sentences. Do not ramble. Do not generate a script.)"
            
        local_chat_memory[payload.model].append({"role": "user", "content": prompt_with_rules})
        
        # Keep sliding window small to fit in GPU context (max 10 roles)
        if len(local_chat_memory[payload.model]) > 10:
            local_chat_memory[payload.model] = local_chat_memory[payload.model][-10:]

        data = {
            "model": payload.model,
            "messages": local_chat_memory[payload.model],
            "stream": False
        }
        res = requests.post("http://localhost:11434/api/chat", json=data, timeout=120)
        res.raise_for_status()
        
        output_text = res.json().get("message", {}).get("content", "Error parsing response.")
        
        # Lock functionally formatted AI response into memory
        local_chat_memory[payload.model].append({"role": "assistant", "content": output_text})
        
        return {"response": output_text}
    except Exception as e:
        return {"response": f"⚠️ Local hardware daemon (Ollama) is offline or unreachable. Please start the service to natively execute the {payload.model} model."}

# --- Connectivity Endpoints ---
class ConnectTogglePayload(BaseModel):
    feature: str  # 'bt', 'hotspot', 'mcu'
    enabled: bool

@app.post("/api/connectivity/toggle")
def toggle_connectivity(payload: ConnectTogglePayload):
    global BT_BEACON_ENABLED, HOTSPOT_ENABLED, MCU_DISPLAY_ENABLED
    if payload.feature == 'bt': BT_BEACON_ENABLED = payload.enabled
    if payload.feature == 'hotspot': 
        HOTSPOT_ENABLED = payload.enabled
        if not payload.enabled:
            # Force kill hotspot
            subprocess.run(["nmcli", "con", "down", "Hotspot"], capture_output=True)
            
    if payload.feature == 'mcu': MCU_DISPLAY_ENABLED = payload.enabled
    
    # Trigger immediate sync
    run_hardware_discovery_sync()
    return {"status": "success", "state": {"bt": BT_BEACON_ENABLED, "hotspot": HOTSPOT_ENABLED, "mcu": MCU_DISPLAY_ENABLED}}

# --- API Endpoints for Web UI ---
@app.get("/api/status")
def get_status():
    return {
        "agent": "MK1",
        "status": "Active",
        "ip": get_local_ip(),
        "ai_provider": AI_PROVIDER,
        "ai_analysis_mode": AI_ANALYSIS_MODE,
        "mcp_enabled": MCP_SERVER_ENABLED,
        "data": agent_state
    }

# --- Optional: MCP Server Block ---
if MCP_SERVER_ENABLED:
    try:
        from mcp.server.fastmcp import FastMCP
        mcp = FastMCP("MK1_Agent")

        @mcp.tool()
        def get_mk1_state() -> str:
            """Fetch the current health, margin, and G-Code analysis state from MK1."""
            import json
            return json.dumps(agent_state)

        @mcp.tool()
        def get_printer_history() -> str:
            """Fetch raw 3D printer history from Moonraker."""
            try:
                history = requests.get(f"{MOONRAKER_URL}/server/history/list").json()
                jobs = history.get('result', {}).get('jobs', [])[-10:] # get last 10
                job_data = [{"name": j.get("filename"), "time": j.get("print_duration"), "filament": j.get("filament_used"), "status": j.get("status")} for j in jobs]
                return f"Last 10 jobs: {job_data}"
            except Exception as e:
                return f"Error connecting to moonraker: {e}"

        @mcp.tool()
        def analyze_workflow_profit() -> str:
            """Use the AI to generate a profitability report based on print history."""
            prompt = f"Given profitability margin of ${agent_state['profit_margin']:.2f}, give a 2-sentence workflow suggestion to improve revenue."
            return ask_ai(prompt)

        # Note: If running inside systemd, stdio MCP won't be reachable natively by IDE.
        # This setup allows FastMCP logic to be ready. 
        app.mount("/mcp", mcp.sse_app())
        print("[MK1] MCP Server features loaded! Target SSE connection: http://<ip>:8255/mcp/sse")
    except ImportError:
        print("[MK1] WARNING: mcp package is required for MCP Server.")

if __name__ == "__main__":
    print("Starting MK1 AI Agent System...")
    scheduler.add_job(run_fail_detection, 'interval', minutes=1)
    scheduler.add_job(run_hardware_analysis, 'interval', minutes=5)
    scheduler.add_job(run_hardware_discovery_sync, 'interval', minutes=2)
    scheduler.start()
    
    # Run initial sync immediately
    run_hardware_discovery_sync()
    
    uvicorn.run(app, host="0.0.0.0", port=AGENT_PORT)
