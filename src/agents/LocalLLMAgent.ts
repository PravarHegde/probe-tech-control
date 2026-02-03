import { Agent, AgentContext } from './AgentInterface'

export class LocalLLMAgent implements Agent {
    id = 'local-llm-agent'
    name = 'Local LLM (Ollama)'
    description = 'Connects to local Ollama instance'

    async process(input: string, context: AgentContext): Promise<string> {
        return "⚠️ Local LLM not connected. Ensure Ollama is running on localhost:11434."
    }

    getCapabilities(): string[] {
        return ['local', 'private']
    }
}
