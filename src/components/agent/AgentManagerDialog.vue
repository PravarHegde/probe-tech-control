<template>
    <v-dialog v-model="internalShow" max-width="700px">
        <v-card class="glass-panel">
            <v-card-title class="headline">
                <v-icon left>mdi-robot-confused</v-icon>
                Manage AI Agents
            </v-card-title>
            
            <v-tabs v-model="tab" background-color="transparent" show-arrows centered>
                <v-tab>Installed</v-tab>
                <v-tab>Marketplace</v-tab>
                <v-tab>Custom Link</v-tab>
                <v-tab>Global Settings</v-tab>
            </v-tabs>

            <v-card-text class="pt-4">
                <v-tabs-items v-model="tab" class="transparent">
                    <!-- Tab 1: Installed Agents -->
                    <v-tab-item>
                        <v-list two-line subheader class="transparent">
                            <v-subheader v-if="installedAgents.length === 0">No agents installed. Go to Marketplace to add one.</v-subheader>
                            <v-list-item v-for="agent in installedAgents" :key="agent.id">
                                <v-list-item-avatar>
                                    <v-icon :class="isActive(agent.id) ? 'primary--text' : ''">mdi-robot</v-icon>
                                </v-list-item-avatar>
                                
                                <v-list-item-content>
                                    <v-list-item-title>{{ agent.name }}</v-list-item-title>
                                    <v-list-item-subtitle>{{ agent.description }}</v-list-item-subtitle>
                                </v-list-item-content>
                                
                                <v-list-item-action>
                                     <v-btn v-if="!isActive(agent.id)" small color="primary" @click="activate(agent.id)">Activate</v-btn>
                                     <v-chip v-else small color="success" outlined>Active</v-chip>
                                </v-list-item-action>
                                
                                <v-list-item-action>
                                    <v-btn small text color="error" @click="uninstall(agent.id)">
                                        <v-icon left small>mdi-delete</v-icon>
                                        Remove
                                    </v-btn>
                                </v-list-item-action>
                            </v-list-item>
                        </v-list>
                    </v-tab-item>

                    <!-- Tab 2: Marketplace -->
                    <v-tab-item>
                        <v-list two-line subheader class="transparent">
                             <v-subheader>Available for Download</v-subheader>
                             <v-list-item v-for="agent in marketplaceAgents" :key="agent.id">
                                <v-list-item-avatar>
                                    <v-icon>mdi-cloud-download</v-icon>
                                </v-list-item-avatar>
                                
                                <v-list-item-content>
                                    <v-list-item-title>{{ agent.name }}</v-list-item-title>
                                    <v-list-item-subtitle>{{ agent.description }}</v-list-item-subtitle>
                                </v-list-item-content>
                                
                                <v-list-item-action>
                                    <v-btn v-if="!isInstalled(agent.id)" small color="secondary" @click="install(agent.id)">
                                        <v-icon left>mdi-download</v-icon> Download
                                    </v-btn>
                                    <v-chip v-else small outlined>Installed</v-chip>
                                </v-list-item-action>
                            </v-list-item>
                        </v-list>
                        
                        <v-divider class="my-4"></v-divider>
                        
                        <div class="px-3">
                            <div class="subtitle-1 font-weight-bold mb-2">Local Model Hub (Ollama)</div>
                            <div class="d-flex align-center mb-2">
                                <v-text-field v-model="pendingModel" label="Model Name (e.g. llama3)" dense outlined hide-details class="mr-2"></v-text-field>
                                <v-btn color="secondary" :loading="downloading" @click="downloadModel">
                                    <v-icon left>mdi-cloud-download</v-icon> Pull
                                </v-btn>
                            </div>
                            <div class="caption grey--text mb-4">Streams model directly to local hardware. Target active agent must be MK1 for proxy bridging.</div>
                        </div>
                    </v-tab-item>

                    <!-- Tab 3: Custom Link -->
                    <v-tab-item>
                        <div class="px-2 pt-4">
                            <div class="subtitle-2 mb-2">Connect to a generic HTTP Agent</div>
                            <v-text-field v-model="newName" label="Agent Name" dense outlined hide-details class="mb-2"></v-text-field>
                            <v-text-field v-model="newUrl" label="API URL" dense outlined hide-details placeholder="http://..." class="mb-4"></v-text-field>
                            <v-btn block color="secondary" :disabled="!isValid" :loading="adding" @click="addCustomAgent">
                                <v-icon left>mdi-link-plus</v-icon> Add Agent
                            </v-btn>
                        </div>
                    </v-tab-item>

                    <!-- Tab 4: Models & APIs -->
                    <v-tab-item>
                        <div class="px-3 pt-4 pb-2" style="max-height: 400px; overflow-y: auto;">
                            <div class="subtitle-1 font-weight-bold mb-2">Cloud AI API</div>
                            <v-select v-model="settingsProvider" :items="['openai', 'gemini']" label="AI Provider" dense outlined hide-details class="mb-2"></v-select>
                            <v-text-field v-model="settingsApiKey" label="API Key" type="password" dense outlined hide-details class="mb-4"></v-text-field>

                            <v-divider class="mb-4"></v-divider>

                            <div class="subtitle-1 font-weight-bold mb-2">Advanced Context</div>
                            <v-switch v-model="settingsMcp" label="Enable MCP Server (Tools)" dense hide-details class="mb-4"></v-switch>

                            <v-divider class="mb-4"></v-divider>



                            <v-btn block color="primary" class="mt-2" :loading="savingSettings" @click="saveGlobalSettings">
                                Save Configuration
                            </v-btn>
                        </div>
                    </v-tab-item>
                </v-tabs-items>
            </v-card-text>
            
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text @click="internalShow = false">Close</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>

<script lang="ts">
import { Component, Vue, Prop, Watch } from 'vue-property-decorator'
import { agentRegistry } from '@/agents/AgentRegistry'

@Component
export default class AgentManagerDialog extends Vue {
    @Prop({ default: false }) value!: boolean

    get internalShow() {
        return this.value
    }

    set internalShow(val: boolean) {
        this.$emit('input', val)
    }

    tab = 0
    installedAgents = agentRegistry.getInstalledAgents()
    marketplaceAgents = agentRegistry.getAvailableAgents()
    activeId = agentRegistry.getActiveAgent().id
    
    newName = ''
    newUrl = ''
    adding = false
    
    settingsProvider = 'openai'
    settingsApiKey = ''
    settingsMcp = false
    pendingModel = ''
    downloading = false
    savingSettings = false
    
    @Watch('value')
    onOpen(val: boolean) {
        if (val) {
            this.refresh()
        }
    }
    
    refresh() {
        this.installedAgents = agentRegistry.getInstalledAgents()
        this.marketplaceAgents = agentRegistry.getAvailableAgents()
        this.activeId = agentRegistry.getActiveAgent().id
    }
    
    isActive(id: string) {
        return this.activeId === id
    }
    
    isInstalled(id: string) {
        return agentRegistry.isInstalled(id)
    }
    
    activate(id: string) {
        agentRegistry.setActiveAgent(id)
        this.refresh()
        this.$emit('agent-changed')
    }
    
    async install(id: string) {
        if (id === 'llama-local' || id === 'gemma-local') {
            this.downloading = true
            const targetModel = id === 'llama-local' ? 'llama3' : 'gemma:2b'
            try {
                // Trigger the live Ollama proxy pull
                await fetch(`${this.activeAgentUrl}/api/models/pull`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ name: targetModel })
                })
                alert(`Successfully pulled ${targetModel} natively into hardware via Ollama!`)
            } catch (e) {
                console.error("Local hardware pull failed:", e)
                alert("Native Ollama pull failed. Check connection.")
            }
            this.downloading = false
        }
        
        agentRegistry.install(id)
        this.refresh()
        // Switch to Installed tab to show it's there
        this.tab = 0
    }

    uninstall(id: string) {
        agentRegistry.uninstall(id)
        this.refresh()
        this.$emit('agent-changed') // In case active agent was removed
    }
    
    get isValid() {
        return this.newName.trim().length > 0 && this.newUrl.trim().length > 0
    }
    
    async addCustomAgent() {
        if (!this.isValid) return
        this.adding = true

        agentRegistry.addCustomAgent(this.newName, this.newUrl)
        this.newName = ''
        this.newUrl = ''
        this.adding = false
        this.refresh()
        this.tab = 0
    }

    get activeAgentUrl() {
        const agent = agentRegistry.getActiveAgent()
        return agent && agent.url ? agent.url.replace(/\/$/, "") : 'http://192.168.1.15:8255'
    }

    async saveGlobalSettings() {
        this.savingSettings = true
        try {
            await fetch(`${this.activeAgentUrl}/api/config`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    mcp_enabled: this.settingsMcp,
                    ai_api_key: this.settingsApiKey || null,
                    ai_provider: this.settingsProvider
                })
            })
            alert("Configuration forcefully synced to backend!")
        } catch (e) {
            console.error("Failed configuration push", e)
            alert("Failed to contact backend. Make sure MK1 is running!")
        }
        this.savingSettings = false
    }

    async downloadModel() {
        if (!this.pendingModel) return
        this.downloading = true
        try {
            await fetch(`${this.activeAgentUrl}/api/models/pull`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ name: this.pendingModel })
            })
            alert("Local Hardware Model Download Sequence Initiated!")
            this.pendingModel = ''
        } catch (e) {
            console.error(e)
            alert("Ollama bridging failed.")
        }
        this.downloading = false
    }
}
</script>

<style scoped>
.glass-panel {
    backdrop-filter: blur(10px);
    background: rgba(30, 30, 30, 0.95) !important; 
}
.theme--dark.v-list {
    background: transparent;
}
</style>
