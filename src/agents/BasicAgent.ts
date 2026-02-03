import { Agent, AgentContext } from './AgentInterface'

export class BasicAgent implements Agent {
    id = 'basic-agent'
    name = 'Basic Rules Agent'
    description = 'Standard rule-based agent for status and basic control.'

    async process(input: string, context: AgentContext): Promise<string> {
        const text = input.toLowerCase()
        const store = context.store

        // Status Intent
        if (text.includes('status') || text.includes('progress') || text.includes('state')) {
            const printPercent = store.getters['printer/getPrintPercent']
            const percent = (printPercent * 100).toFixed(1)
            const eta = store.getters['printer/getEstimatedTimeETAFormat']

            if (percent === '0.0' && eta === '--') {
                return `The printer is currently idle. Ready for your next job!`
            }
            return `Current Status:\n- Progress: ${percent}%\n- ETA: ${eta}`
        }

        // Temperature Intent
        if (text.includes('temp') || text.includes('heat') || text.includes('hot')) {
            let response = 'Current Temperatures:\n'

            // Extruders
            const extruders = store.getters['printer/getExtruders']
            const getPrinterObject = store.getters['printer/getPrinterObject']

            extruders.forEach((ext: any) => {
                const printerExt = getPrinterObject(ext.key)
                if (printerExt) {
                    response += `- ${ext.name}: ${printerExt.temperature.toFixed(1)}°C / ${printerExt.target.toFixed(1)}°C\n`
                }
            })

            // Heater Bed
            const bed = getPrinterObject('heater_bed')
            if (bed) {
                response += `- Bed: ${bed.temperature.toFixed(1)}°C / ${bed.target.toFixed(1)}°C\n`
            }

            return response
        }

        // Home Intent
        if (text.includes('home') || text.includes('g28')) {
            store.dispatch('printer/sendGcode', 'G28')
            return "Sending G28 (Home All) command..."
        }

        // Stop/Pause Intent
        if (text.includes('stop') || text.includes('cancel')) {
            return "To cancel the print, please use the main dashboard controls for safety."
        }

        if (text.includes('pause')) {
            store.dispatch('printer/sendGcode', 'PAUSE')
            return "Sending PAUSE command..."
        }

        if (text.includes('help')) {
            return "I can help with:\n- 'Status': Check print progress\n- 'Temp': Check temperatures\n- 'Home': Home all axes\n- 'Pause': Pause the print"
        }

        return "I didn't capture that. Try asking for 'status' or 'temp', or check the quick actions below."
    }

    getCapabilities(): string[] {
        return ['status', 'temp', 'home', 'pause']
    }
}
