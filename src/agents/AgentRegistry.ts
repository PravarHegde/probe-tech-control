import { Agent } from './AgentInterface'
import { BasicAgent } from './BasicAgent'
import { CustomAgent } from './CustomAgent'

class AgentRegistry {
    private agents: Map<string, Agent> = new Map()
    private activeAgentId: string = 'basic-agent'

    constructor() {
        // Register default agent
        this.register(new BasicAgent())

        // Load custom agents from storage
        const customAgents = JSON.parse(localStorage.getItem('customAgents') || '[]')
        customAgents.forEach((data: any) => {
            this.register(new CustomAgent(data.id, data.name, data.url))
        })

        // Load active agent from storage
        const storedId = localStorage.getItem('activeAgentId')
        if (storedId && this.agents.has(storedId)) {
            this.activeAgentId = storedId
        }
    }

    register(agent: Agent) {
        this.agents.set(agent.id, agent)
    }

    // Specifically for adding new custom agents from UI
    addCustomAgent(name: string, url: string) {
        const id = 'custom-' + Date.now()
        const agent = new CustomAgent(id, name, url)
        this.register(agent)
        this.saveCustomAgents()
        return agent
    }

    removeAgent(id: string) {
        if (id === 'basic-agent') return // Cannot remove default
        this.agents.delete(id)
        this.saveCustomAgents()
        if (this.activeAgentId === id) {
            this.setActiveAgent('basic-agent')
        }
    }

    private saveCustomAgents() {
        const custom = Array.from(this.agents.values())
            .filter(a => a instanceof CustomAgent)
            .map(a => ({
                id: a.id,
                name: a.name,
                url: (a as CustomAgent).url
            }))
        localStorage.setItem('customAgents', JSON.stringify(custom))
    }

    getAgent(id: string): Agent | undefined {
        return this.agents.get(id)
    }

    getAllAgents(): Agent[] {
        return Array.from(this.agents.values())
    }

    getActiveAgent(): Agent {
        return this.agents.get(this.activeAgentId) || this.agents.get('basic-agent')!
    }

    setActiveAgent(id: string) {
        if (this.agents.has(id)) {
            this.activeAgentId = id
            localStorage.setItem('activeAgentId', id)
        }
    }
}

export const agentRegistry = new AgentRegistry()
