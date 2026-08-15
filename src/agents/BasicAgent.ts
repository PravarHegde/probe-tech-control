/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
import { Agent, AgentContext } from './AgentInterface'

export class BasicAgent implements Agent {
    id = 'basic-agent'
    name = 'Basic Rules Agent'
    description = 'Standard rule-based agent for status and basic control.'

    private calibrationState = {
        active: false,
        step: 0,
        filament: '',
        extraOffset: 0
    }

    async process(input: string, context: AgentContext): Promise<string> {
        const text = input.toLowerCase().trim()
        const store = context.store

        // Calibration Wizard State Machine
        if (this.calibrationState.active) {
            return this.handleCalibrationStep(text, store)
        }

        if (text === 'calibrate offset' || text.includes('calibrate z') || text === 'calibrate') {
            this.calibrationState.active = true
            this.calibrationState.step = 1
            this.calibrationState.filament = ''
            this.calibrationState.extraOffset = 0
            return "Starting Z-Offset Calibration Wizard!\n\nWhat filament will you be printing? (e.g. PLA, PETG, ABS)"
        }

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
            return "I can help with:\n- 'Status': Check print progress\n- 'Temp': Check temperatures\n- 'Home': Home all axes\n- 'Pause': Pause the print\n- 'Calibrate offset': Start the Z-offset wizard"
        }

        return "I didn't capture that. Try asking for 'status' or 'temp', or check the quick actions below."
    }

    private handleCalibrationStep(text: string, store: any): string {
        if (text === 'abort' || text === 'cancel') {
            this.calibrationState.active = false
            store.dispatch('printer/sendGcode', 'ABORT')
            return "Calibration wizard cancelled."
        }

        // Step 1: Filament Selection
        if (this.calibrationState.step === 1) {
            this.calibrationState.filament = text.toUpperCase()
            if (this.calibrationState.filament === 'PETG') {
                this.calibrationState.extraOffset = 0.04
            }
            
            // Initiate sequence
            const center_x = 117.5 // Default fallback, robust solution would fetch config limits
            const center_y = 117.5
            
            store.dispatch('printer/sendGcode', 'G28')
            setTimeout(() => store.dispatch('printer/sendGcode', `G0 X${center_x} Y${center_y} Z10 F3000`), 500)
            setTimeout(() => store.dispatch('printer/sendGcode', 'PROBE_CALIBRATE'), 1000)

            this.calibrationState.step = 2
            
            let msg = `Got it, optimizing for ${this.calibrationState.filament}!`
            if (this.calibrationState.extraOffset > 0) {
                msg += ` I'll automatically add +${this.calibrationState.extraOffset}mm clearance so it doesn't stick too hard.`
            }
            msg += `\n\nI am currently homing the printer and starting the probe sequence...`
            msg += `\n\nOnce it stops, place a piece of paper under the nozzle. How many mm do you want to move DOWN? (e.g. 5, 1, 0.5, 0.1)\nOr type 'yes' if the paper firmly grips.`
            return msg
        }

        // Step 2: Paper Test Loop
        if (this.calibrationState.step === 2) {
            if (text === 'y' || text === 'yes') {
                if (this.calibrationState.extraOffset > 0) {
                    store.dispatch('printer/sendGcode', `TESTZ Z=${this.calibrationState.extraOffset}`)
                }
                store.dispatch('printer/sendGcode', 'ACCEPT')
                this.calibrationState.step = 3
                return `Perfect! Physical zero set.\nDo you want to permanently SAVE_CONFIG and restart Klipper now? (yes/no)`
            }

            const val = parseFloat(text)
            if (!isNaN(val)) {
                if (val > 0) {
                    store.dispatch('printer/sendGcode', `TESTZ Z=-${val}`)
                    return `Moving down ${val}mm...\nStill free? Enter next amount, or type 'yes' if it grips.`
                } else {
                    store.dispatch('printer/sendGcode', `TESTZ Z=${Math.abs(val)}`)
                    return `Moving up ${Math.abs(val)}mm...\nStill free? Enter next amount, or type 'yes' if it grips.`
                }
            } else {
                return "Please enter a valid number (e.g. 1, 0.5), or 'yes' if it grips."
            }
        }

        // Step 3: Save Config
        if (this.calibrationState.step === 3) {
            this.calibrationState.active = false
            if (text === 'y' || text === 'yes') {
                store.dispatch('printer/sendGcode', 'SAVE_CONFIG')
                return "Saving config! Klipper is restarting now."
            } else {
                return "Calibration applied for this session, but not saved. Happy printing!"
            }
        }

        return "Invalid calibration state."
    }

    getCapabilities(): string[] {
        return ['status', 'temp', 'home', 'pause', 'calibrate offset']
    }
}
