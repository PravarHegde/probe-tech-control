<template>
    <div class="agent-dashboard">
        <v-row>
            <v-col cols="12" md="8">
                <v-card class="glass-panel mb-4">
                    <v-card-title class="headline primary--text d-flex justify-space-between">
                        <div>
                            <v-icon left color="primary">{{ mdiRobot }}</v-icon>
                            AI Job Planner
                            <span class="subtitle-2 grey--text ml-2">({{ activeAgentName }})</span>
                        </div>
                        <v-btn small text color="primary" @click="showManager = true">
                            <v-icon left>mdi-cog</v-icon> Manage Agents
                        </v-btn>
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
                             <v-chip v-for="cap in capabilities" :key="cap" outlined small class="mr-2 mb-2" @click="quickAction(cap)">
                                {{ capitalize(cap) }}
                             </v-chip>
                        </div>

                        <v-text-field
                            v-model="newMessage"
                            placeholder="Ask me anything about your 3D printing tasks..."
                            outlined
                            dense
                            class="mt-2"
                            :disabled="processing"
                            @keydown.enter="sendMessage"
                        >
                            <template v-slot:append>
                                <v-icon @click="sendMessage" :disabled="processing">{{ mdiSend }}</v-icon>
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
        
        <agent-manager-dialog v-model="showManager" @agent-changed="onAgentChanged" />
    </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import { mdiRobot, mdiSend, mdiHeartPulse, mdiFlash, mdiCheckCircleOutline } from '@mdi/js'
import { agentRegistry } from '@/agents/AgentRegistry'
import AgentManagerDialog from '@/components/agent/AgentManagerDialog.vue'

@Component({
    components: {
        AgentManagerDialog
    }
})
export default class AgentDashboard extends Vue {
    mdiRobot = mdiRobot
    mdiSend = mdiSend
    mdiHeartPulse = mdiHeartPulse
    mdiFlash = mdiFlash
    mdiCheckCircleOutline = mdiCheckCircleOutline
    
    newMessage = ''
    messages = [
        {
            id: 1,
            text: 'Hello! I am your intelligent print agent. I can help you check status, temperatures, or control the printer.',
            sender: 'ai',
        },
    ]
    
    showManager = false
    activeAgentName = ''
    capabilities: string[] = []
    processing = false
    
    created() {
        this.updateAgentInfo()
    }
    
    updateAgentInfo() {
        const agent = agentRegistry.getActiveAgent()
        this.activeAgentName = agent.name
        this.capabilities = agent.getCapabilities ? (agent.getCapabilities() || []) : ['status', 'help']
    }
    
    onAgentChanged() {
        this.updateAgentInfo()
        this.messages.push({
            id: Date.now(),
            text: `System: Switched to ${this.activeAgentName}`,
            sender: 'ai'
        })
    }

    quickAction(action: string) {
        this.newMessage = action
        this.sendMessage()
    }

    async sendMessage() {
        if (!this.newMessage.trim() || this.processing) return

        const userText = this.newMessage
        this.messages.push({
            id: Date.now(),
            text: userText,
            sender: 'user',
        })

        this.newMessage = ''
        this.processing = true
        this.scrollToBottom()
        
        // Process Intent via Agent Registry
        try {
            const agent = agentRegistry.getActiveAgent()
            // Construct context
            const context = {
                store: this.$store,
                router: this.$router
            }
            
            const response = await agent.process(userText, context)
            
            this.messages.push({
                id: Date.now() + 1,
                text: response,
                sender: 'ai',
            })
        } catch (e) {
            this.messages.push({
                id: Date.now() + 1,
                text: `Error: ${e.message}`,
                sender: 'ai',
            })
        } finally {
            this.processing = false
            this.scrollToBottom()
        }
    }
    
    capitalize(s: string) {
        return s.charAt(0).toUpperCase() + s.slice(1)
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
.glass-panel {
    background: rgba(45, 45, 45, 0.9); /* Darker background for visibility */
    backdrop-filter: blur(5px);
}
.glass-card {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(5px);
}
</style>
