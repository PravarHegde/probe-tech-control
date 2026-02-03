export interface AgentContext {
    store: any // Vuex store instance
    router: any // Vue router instance
}

export interface Agent {
    id: string
    name: string
    description: string

    // The core processing method
    // Returns a Promise that resolves to the response string
    process(input: string, context: AgentContext): Promise<string>

    // Optional: Return list of capabilities/chips to display
    getCapabilities?(): string[]
}
