<template>
    <div class="agent-dashboard">
        <v-row>
            <v-col cols="12" md="8">
                <v-card class="glass-panel mb-4">
                    <v-card-title class="headline primary--text">
                        <v-icon left color="primary">{{ mdiRobot }}</v-icon>
                        AI Job Planner
                    </v-card-title>
                    <v-card-text>
                        <div class="chat-interface pa-4" style="height: 400px; overflow-y: auto; background: rgba(0,0,0,0.2); border-radius: 8px;">
                            <div v-for="msg in messages" :key="msg.id" class="d-flex mb-2" :class="{ 'justify-end': msg.sender === 'user' }">
                                <v-avatar v-if="msg.sender === 'ai'" size="32" color="primary" class="mr-2">AI</v-avatar>
                                <div
                                    class="pa-2 rounded-lg"
                                    :class="msg.sender === 'user' ? 'primary white--text' : 'glass-card'"
                                    style="max-width: 80%; white-space: pre-wrap;"
                                >
                                    {{ msg.text }}
                                </div>
                                <v-avatar v-if="msg.sender === 'user'" size="32" color="grey darken-3" class="ml-2">Me</v-avatar>
                            </div>
                        </div>

                        <!-- Quick Actions -->
                        <div class="d-flex flex-wrap mt-2">
                             <v-chip outlined small class="mr-2 mb-2" @click="quickAction('status')">Current Status</v-chip>
                             <v-chip outlined small class="mr-2 mb-2" @click="quickAction('temp')">Temperatures</v-chip>
                             <v-chip outlined small class="mr-2 mb-2" @click="quickAction('home')">Home All</v-chip>
                             <v-chip outlined small class="mr-2 mb-2" @click="quickAction('pause')">Pause Print</v-chip>
                        </div>

                        <v-text-field
                            v-model="newMessage"
                            placeholder="Ask me anything about your 3D printing tasks..."
                            outlined
                            dense
                            class="mt-2"
                            @keydown.enter="sendMessage"
                        >
                            <template v-slot:append>
                                <v-icon @click="sendMessage">{{ mdiSend }}</v-icon>
                            </template>
                        </v-text-field>
                    </v-card-text>
                </v-card>
            </v-col>

            <v-col cols="12" md="4">
                <v-card class="glass-panel mb-4">
                    <v-card-title class="headline secondary--text">
                        <v-icon left color="secondary">{{ mdiHeartPulse }}</v-icon>
                        System Health
                    </v-card-title>
                    <v-card-text>
                        <v-list dense color="transparent">
                            <v-list-item>
                                <v-list-item-content>CPU Load</v-list-item-content>
                                <v-list-item-action>
                                    <v-progress-linear value="15" color="secondary" style="width: 100px"></v-progress-linear>
                                </v-list-item-action>
                            </v-list-item>
                             <v-list-item>
                                <v-list-item-content>RAM Usage</v-list-item-content>
                                <v-list-item-action>
                                    <v-progress-linear value="42" color="accent" style="width: 100px"></v-progress-linear>
                                </v-list-item-action>
                            </v-list-item>
                             <v-list-item>
                                <v-list-item-content>Network Latency</v-list-item-content>
                                <v-list-item-action class="success--text">
                                    12ms
                                </v-list-item-action>
                            </v-list-item>
                        </v-list>
                    </v-card-text>
                </v-card>

                <v-card class="glass-panel">
                    <v-card-title class="headline accent--text">
                        <v-icon left color="accent">{{ mdiFlash }}</v-icon>
                        Optimization
                    </v-card-title>
                    <v-card-text>
                        <div class="text-center">
                            <v-icon size="64" color="grey darken-2">{{ mdiCheckCircleOutline }}</v-icon>
                            <div class="mt-2">System Running Optimally</div>
                             <v-btn text color="primary" class="mt-2">Run Diagnostics</v-btn>
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
    </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import { namespace } from 'vuex-class'
const printer = namespace('printer')
import { mdiRobot, mdiSend, mdiHeartPulse, mdiFlash, mdiCheckCircleOutline } from '@mdi/js'



@Component
export default class AgentDashboard extends Vue {
    mdiRobot = mdiRobot
    mdiSend = mdiSend
    mdiHeartPulse = mdiHeartPulse
    mdiFlash = mdiFlash
    mdiCheckCircleOutline = mdiCheckCircleOutline
    
    @printer.Getter('getPrintPercent') printPercent!: number
    @printer.Getter('getEstimatedTimeETAFormat') estimatedTimeETAFormat!: string
    @printer.Getter('getExtruders') extruders!: any[]
    @printer.Getter('getPrinterObject') getPrinterObject!: (name: string) => any
    @printer.Action('sendGcode') sendGcode!: (gcode: string) => void

    newMessage = ''
    messages = [
        {
            id: 1,
            text: 'Hello! I am your intelligent print agent. I can help you check status, temperatures, or control the printer. Try typing "status" or "temp".',
            sender: 'ai',
        },
    ]

    quickAction(action: string) {
        this.newMessage = action
        this.sendMessage()
    }

    sendMessage() {
        if (!this.newMessage.trim()) return

        const userText = this.newMessage
        this.messages.push({
            id: Date.now(),
            text: userText,
            sender: 'user',
        })

        this.newMessage = ''
        
        // Process Intent
        setTimeout(() => {
            const response = this.processMessage(userText.toLowerCase())
            this.messages.push({
                id: Date.now() + 1,
                text: response,
                sender: 'ai',
            })
            this.scrollToBottom()
        }, 500)

        this.scrollToBottom()
    }

    processMessage(text: string): string {
        // Status Intent
        if (text.includes('status') || text.includes('progress') || text.includes('state')) {
            const percent = (this.printPercent * 100).toFixed(1)
            const eta = this.estimatedTimeETAFormat
            if (percent === '0.0' && eta === '--') {
                 return `The printer is currently idle. Ready for your next job!`
            }
            return `Current Status:\n- Progress: ${percent}%\n- ETA: ${eta}`
        }

        // Temperature Intent
        if (text.includes('temp') || text.includes('heat') || text.includes('hot')) {
            let response = 'Current Temperatures:\n'
            
            // Extruders
            this.extruders.forEach((ext: any) => {
                const printerExt = this.getPrinterObject(ext.key)
                if (printerExt) {
                    response += `- ${ext.name}: ${printerExt.temperature.toFixed(1)}°C / ${printerExt.target.toFixed(1)}°C\n`
                }
            })

            // Heater Bed
            const bed = this.getPrinterObject('heater_bed')
            if (bed) {
                response += `- Bed: ${bed.temperature.toFixed(1)}°C / ${bed.target.toFixed(1)}°C\n`
            }
            
            return response
        }

        // Home Intent
        if (text.includes('home') || text.includes('g28')) {
            this.sendGcode('G28')
            return "Sending G28 (Home All) command..."
        }

        // Stop/Pause Intent
        if (text.includes('stop') || text.includes('cancel')) {
            // In a real agent, we might ask for confirmation.
            // For now, we'll give a warning.
            return "To cancel the print, please use the main dashboard controls for safety."
        }
        
        if (text.includes('pause')) {
             this.sendGcode('PAUSE')
             return "Sending PAUSE command..."
        }
        
        if (text.includes('help')) {
            return "I can help with:\n- 'Status': Check print progress\n- 'Temp': Check temperatures\n- 'Home': Home all axes\n- 'Pause': Pause the print"
        }

        return "I didn't capture that. Try asking for 'status' or 'temp', or check the quick actions below."
    }

    scrollToBottom() {
        this.$nextTick(() => {
            const container = this.$el.querySelector('.chat-interface')
            if (container) container.scrollTop = container.scrollHeight
        })
    }
}
</script>

<style scoped>
.glass-card {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(5px);
}
</style>
