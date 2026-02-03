<template>
    <v-dialog v-model="internalShow" max-width="600px">
        <v-card class="glass-panel">
            <v-card-title class="headline">
                <v-icon left>mdi-robot-confused</v-icon>
                Manage AI Agents
            </v-card-title>
            
            <v-card-text>
                <v-list two-line subheader class="transparent">
                    <v-subheader>Installed Agents</v-subheader>
                    <v-list-item v-for="agent in agents" :key="agent.id">
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
                        
                        <v-list-item-action v-if="!isBuiltIn(agent.id)">
                            <v-btn icon small color="error" @click="remove(agent.id)">
                                <v-icon>mdi-delete</v-icon>
                            </v-btn>
                        </v-list-item-action>
                    </v-list-item>
                </v-list>
                
                <v-divider class="my-3"></v-divider>
                
                <div class="px-2">
                    <div class="subtitle-2 mb-2">Add Custom Agent (Link)</div>
                    <v-text-field v-model="newName" label="Agent Name" dense outlined hide-details class="mb-2"></v-text-field>
                    <v-text-field v-model="newUrl" label="API URL" dense outlined hide-details placeholder="https://..." class="mb-2"></v-text-field>
                    <v-btn block color="secondary" :disabled="!isValid" @click="addAgent">
                        <v-icon left>mdi-download</v-icon> Download / Add Agent
                    </v-btn>
                </div>
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
// import { mdiRobot, mdiDelete, mdiDownload, mdiRobotConfused } from '@mdi/js' // Icons managed by Vuetify generally, but let's see.

@Component
export default class AgentManagerDialog extends Vue {
    @Prop({ default: false }) value!: boolean

    get internalShow() {
        return this.value
    }

    set internalShow(val: boolean) {
        this.$emit('input', val)
    }

    agents = agentRegistry.getAllAgents()
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
        this.agents = agentRegistry.getAllAgents()
        this.activeId = agentRegistry.getActiveAgent().id
    }
    
    isActive(id: string) {
        return this.activeId === id
    }
    
    isBuiltIn(id: string) {
        return id === 'basic-agent'
    }
    
    activate(id: string) {
        agentRegistry.setActiveAgent(id)
        this.refresh()
        this.$emit('agent-changed')
    }
    
    remove(id: string) {
        agentRegistry.removeAgent(id)
        this.refresh()
    }
    
    get isValid() {
        return this.newName.trim().length > 0 && this.newUrl.trim().length > 0
    }
    
    addAgent() {
        if (!this.isValid) return
        agentRegistry.addCustomAgent(this.newName, this.newUrl)
        this.newName = ''
        this.newUrl = ''
        this.refresh()
    }
}
</script>

<style scoped>
.glass-panel {
    backdrop-filter: blur(10px);
    background: rgba(30, 30, 30, 0.9) !important; 
}
</style>
