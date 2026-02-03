<template>
    <v-dialog v-model="internalShow" max-width="700px">
        <v-card class="glass-panel">
            <v-card-title class="headline">
                <v-icon left>mdi-robot-confused</v-icon>
                Manage AI Agents
            </v-card-title>
            
            <v-tabs v-model="tab" background-color="transparent" grow>
                <v-tab>Installed</v-tab>
                <v-tab>Marketplace</v-tab>
                <v-tab>Custom Link</v-tab>
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
                    </v-tab-item>

                    <!-- Tab 3: Custom Link -->
                    <v-tab-item>
                        <div class="px-2 pt-4">
                            <div class="subtitle-2 mb-2">Connect to a generic HTTP Agent</div>
                            <v-text-field v-model="newName" label="Agent Name" dense outlined hide-details class="mb-2"></v-text-field>
                            <v-text-field v-model="newUrl" label="API URL" dense outlined hide-details placeholder="https://..." class="mb-2"></v-text-field>
                            <v-btn block color="secondary" :disabled="!isValid" @click="addCustomAgent">
                                <v-icon left>mdi-link-plus</v-icon> Add Agent
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
    
    install(id: string) {
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
    
    addCustomAgent() {
        if (!this.isValid) return
        agentRegistry.addCustomAgent(this.newName, this.newUrl)
        this.newName = ''
        this.newUrl = ''
        this.refresh()
        this.tab = 0
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
