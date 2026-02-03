import { Agent, AgentContext } from './AgentInterface'
import axios from 'axios'

export class CustomAgent implements Agent {
    id: string
    name: string
    description: string
    url: string

    constructor(id: string, name: string, url: string) {
        this.id = id
        this.name = name
        this.url = url
        this.description = `External Agent connected to ${url}`
    }

    async process(input: string, context: AgentContext): Promise<string> {
        try {
            // Send input to the external URL
            // Expected format: POST { input: string, context: ... }
            const response = await axios.post(this.url, {
                input,
                // We send a simplified context to avoid circular structures or sending the whole store
                printerState: {
                    status: context.store.state.printer.status,
                    temps: context.store.getters['printer/getExtruders'],
                }
            })

            // Expected response: { response: string }
            if (response.data && response.data.response) {
                return response.data.response
            } else {
                return "Error: Invalid response format from agent."
            }
        } catch (error) {
            console.error('Custom Agent Error:', error)
            return `Error communicating with agent: ${error.message}`
        }
    }
}
