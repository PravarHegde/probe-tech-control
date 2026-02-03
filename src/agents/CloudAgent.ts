import { Agent, AgentContext } from './AgentInterface'

export class CloudAgent implements Agent {
    id = 'cloud-agent'
    name = 'Cloud Agent (OpenAI)'
    description = 'Connects to OpenAI/DeepSeek API (Requires Key)'

    async process(input: string, context: AgentContext): Promise<string> {
        return "⚠️ Cloud Agent not configured. Please add your API Key in Settings (Coming Soon)."
    }

    getCapabilities(): string[] {
        return ['chat', 'reasoning']
    }
}
