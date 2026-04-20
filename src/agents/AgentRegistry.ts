import { Agent } from './AgentInterface'
import { BasicAgent } from './BasicAgent'
import { CustomAgent } from './CustomAgent'
import { CloudAgent } from './CloudAgent'
import { LocalLLMAgent } from './LocalLLMAgent'

class LlamaAgent implements Agent {
    id = 'llama-local'
    name = 'Llama 3 Local'
    description = 'High-performance general reasoning model'
    async process(input: string, context: any): Promise<string> {
        try {
            const url = `http://${window.location.hostname}:8255/api/chat/local`
            const res = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ model: 'llama3', prompt: input })
            })
            const data = await res.json()
            return data.response
        } catch(e) {
            return "Llama is initializing offline mode. Hardware daemon proxy unavailable."
        }
    }
}

class GemmaAgent implements Agent {
    id = 'gemma-local'
    name = 'Gemma Local'
    description = 'Lightweight, highly-efficient embedded AI'
    async process(input: string, context: any): Promise<string> {
        try {
            const url = `http://${window.location.hostname}:8255/api/chat/local`
            const res = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ model: 'gemma:2b', prompt: input })
            })
            const data = await res.json()
            return data.response
        } catch(e) {
            return "Gemma is initializing offline mode. Hardware daemon proxy unavailable."
        }
    }
}

class ProBharathGemmaAgent implements Agent {
    id = 'gemma-probharath'
    name = 'ProBharath Industrial Gemma'
    description = 'Custom trained text briefing for manufacturing (Farm-Grade)'
    async process(input: string, context: any): Promise<string> {
        try {
            const url = `http://${window.location.hostname}:8255/api/chat/local`
            const res = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ model: 'probharath-gemma', prompt: input })
            })
            const data = await res.json()
            return data.response
        } catch(e) {
            return "Hardware daemon proxy unavailable."
        }
    }
}

class TinyLlamaAgent implements Agent {
    id = 'tinyllama-probharath'
    name = 'ProBharath TinyLlama (Pi Edition)'
    description = 'Highly compressed 600MB model for Raspberry Pi & Android'
    async process(input: string, context: any): Promise<string> {
        try {
            const url = `http://${window.location.hostname}:8255/api/chat/local`
            const res = await fetch(url, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ model: 'probharath-lite', prompt: input })
            })
            const data = await res.json()
            return data.response
        } catch(e) {
            return "Hardware daemon proxy unavailable."
        }
    }
}

class CoreAgent implements Agent {
    id = 'core-agent'
    name = 'Core System'
    description = 'Minimal fallback agent.'
    async process(input: string): Promise<string> {
        return "No agent is active. Please install or activate an agent from the Manager."
    }
}

class AgentRegistry {
    private installedAgents: Map<string, Agent> = new Map()
    private availableTemplates: Map<string, Agent> = new Map()
    private activeAgentId: string = 'core-agent'

    // Core fallback
    private coreAgent = new CoreAgent()

    constructor() {
        // 1. Register Core (Always available, invisible in list)
        this.installedAgents.set(this.coreAgent.id, this.coreAgent)

        // 1.5 Register Built-In MK1 Agent Exception
        const localHost = window.location.hostname
        const mk1Agent = new CustomAgent('mk1-builtin', 'Built-in MK1 Agent', `http://${localHost}:8255`)
        this.installedAgents.set(mk1Agent.id, mk1Agent)

        // 2. Define Marketplace Templates
        const templates = [
            new BasicAgent(),
            new CloudAgent(),
            new LlamaAgent(),
            new GemmaAgent(),
            new ProBharathGemmaAgent(),
            new TinyLlamaAgent()
        ]
        templates.forEach(t => this.availableTemplates.set(t.id, t))

        // 3. Load INSTALLED agents from storage
        // Format: { id: string, type: 'basic'|'cloud'|'local'|'custom', args?: any }
        const installedData = JSON.parse(localStorage.getItem('installedAgents') || '[]')

        // If empty (fresh install), do NOT install anything by default (per user request for "light")
        // OR: Should we install BasicAgent by default? User said "default no agents or very simple".
        // Let's stick to CoreAgent as default if nothing is installed.

        installedData.forEach((data: any) => {
            if (this.availableTemplates.has(data.id)) {
                // It's a template we know
                this.installedAgents.set(data.id, this.availableTemplates.get(data.id)!)
            } else if (data.type === 'custom') {
                // Rehydrate custom agent
                const agent = new CustomAgent(data.id, data.name, data.url)
                this.installedAgents.set(agent.id, agent)
            }
        })

        // 4. Load Active Agent
        const storedId = localStorage.getItem('activeAgentId')
        if (storedId && this.installedAgents.has(storedId)) {
            this.activeAgentId = storedId
        } else {
            this.activeAgentId = 'core-agent'
        }
    }

    // --- Marketplace Methods ---

    getAvailableAgents(): Agent[] {
        return Array.from(this.availableTemplates.values())
    }

    getInstalledAgents(): Agent[] {
        // Exclude core-agent from UI list
        return Array.from(this.installedAgents.values()).filter(a => a.id !== 'core-agent')
    }

    isInstalled(id: string): boolean {
        return this.installedAgents.has(id)
    }

    install(id: string) {
        if (this.availableTemplates.has(id)) {
            this.installedAgents.set(id, this.availableTemplates.get(id)!)
            this.saveInstalledAgents()
        }
    }

    uninstall(id: string) {
        if (id === 'core-agent') return

        this.installedAgents.delete(id)
        this.saveInstalledAgents()

        // If active agent was uninstalled, fallback to core
        if (this.activeAgentId === id) {
            this.activeAgentId = 'core-agent'
            localStorage.setItem('activeAgentId', 'core-agent')
        }
    }

    // --- Active Agent Methods ---

    getActiveAgent(): Agent {
        return this.installedAgents.get(this.activeAgentId) || this.coreAgent
    }

    setActiveAgent(id: string) {
        if (this.installedAgents.has(id)) {
            this.activeAgentId = id
            localStorage.setItem('activeAgentId', id)
        }
    }

    // --- Custom Agent Methods ---

    addCustomAgent(name: string, url: string) {
        const id = 'custom-' + Date.now()
        const agent = new CustomAgent(id, name, url)
        this.installedAgents.set(id, agent)
        this.saveInstalledAgents()
        return agent
    }

    private saveInstalledAgents() {
        const list = Array.from(this.installedAgents.values())
            .filter(a => a.id !== 'core-agent')
            .map(a => {
                if (a instanceof CustomAgent) {
                    return { id: a.id, type: 'custom', name: a.name, url: a.url }
                }
                return { id: a.id, type: 'template' }
            })
        localStorage.setItem('installedAgents', JSON.stringify(list))
    }
}

export const agentRegistry = new AgentRegistry()
