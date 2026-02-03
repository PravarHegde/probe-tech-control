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
                                    style="max-width: 80%"
                                >
                                    {{ msg.text }}
                                </div>
                                <v-avatar v-if="msg.sender === 'user'" size="32" color="grey darken-3" class="ml-2">Me</v-avatar>
                            </div>
                        </div>
                        <v-text-field
                            v-model="newMessage"
                            placeholder="Ask me anything about your 3D printing tasks..."
                            outlined
                            dense
                            class="mt-4"
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
import { mdiRobot, mdiSend, mdiHeartPulse, mdiFlash, mdiCheckCircleOutline } from '@mdi/js'

@Component
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
            text: 'Hello! I am your intelligent print agent. I can help you optimize your print settings, debug issues, or schedule jobs. How can I assist you today?',
            sender: 'ai',
        },
    ]

    sendMessage() {
        if (!this.newMessage.trim()) return

        // Add user message
        this.messages.push({
            id: Date.now(),
            text: this.newMessage,
            sender: 'user',
        })

        // Simulate AI response (placeholder)
        setTimeout(() => {
            this.messages.push({
                id: Date.now() + 1,
                text: "I'm processing your request... (AI Agent functionality is currently in demo mode)",
                sender: 'ai',
            })
            this.scrollToBottom()
        }, 1000)

        this.newMessage = ''
        this.scrollToBottom()
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
