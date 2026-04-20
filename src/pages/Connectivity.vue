<template>
    <div class="connectivity-page">
        <v-row>
            <v-col cols="12" md="6">
                <!-- Zero-Config Discovery Card -->
                <v-card class="glass-panel mb-4 overflow-hidden">
                    <v-card-title class="headline primary--text">
                        <v-icon left color="primary">mdi-radar</v-icon>
                        Zero-Config Discovery
                    </v-card-title>
                    <v-card-text>
                        <p class="caption grey--text">Broadcast your identity to find the printer headless.</p>
                        
                        <v-list class="transparent-list" dense>
                            <v-list-item>
                                <v-list-item-icon><v-icon color="blue">mdi-bluetooth</v-icon></v-list-item-icon>
                                <v-list-item-content>
                                    <v-list-item-title>Bluetooth IP Beacon</v-list-item-title>
                                    <v-list-item-subtitle>Renames adapter to your IP address</v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="btEnabled" @change="toggleFeature('bt', btEnabled)" color="blue"></v-switch>
                                </v-list-item-action>
                            </v-list-item>

                            <v-list-item>
                                <v-list-item-icon><v-icon color="orange">mdi-wifi-cog</v-icon></v-list-item-icon>
                                <v-list-item-content>
                                    <v-list-item-title>Factory Hotline (Hotspot)</v-list-item-title>
                                    <v-list-item-subtitle>Opens SSID: ProBharath-Factory-{{ localIp }}</v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="hotspotEnabled" @change="toggleFeature('hotspot', hotspotEnabled)" color="orange"></v-switch>
                                </v-list-item-action>
                            </v-list-item>

                            <v-list-item>
                                <v-list-item-icon><v-icon color="success">mdi-monitor-screenshot</v-icon></v-list-item-icon>
                                <v-list-item-content>
                                    <v-list-item-title>MCU LCD Branding</v-list-item-title>
                                    <v-list-item-subtitle>Displays IP on Ender 3 physical screen</v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="mcuEnabled" @change="toggleFeature('mcu', mcuEnabled)" color="success"></v-switch>
                                </v-list-item-action>
                            </v-list-item>
                        </v-list>
                    </v-card-text>
                </v-card>

                <!-- Mobile Connect Card -->
                <v-card class="glass-panel">
                    <v-card-title class="headline info--text">
                        <v-icon left color="info">mdi-qrcode-scan</v-icon>
                        Instant Mobile Sync
                    </v-card-title>
                    <v-card-text class="text-center">
                        <div class="glass-card pa-4 d-inline-block rounded-lg mt-2">
                             <img :src="qrImageUrl" alt="QR Link" v-if="localIp !== '127.0.0.1'" style="width: 150px; filter: invert(1);" />
                             <v-icon size="150" color="white" v-else>mdi-qrcode</v-icon>
                        </div>
                        <div class="mt-4 subtitle-1">
                            Scan to visit http://{{ localIp }}:8255
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>

            <v-col cols="12" md="6">
                <!-- Cloud Bridge & Harvesting -->
                <v-card class="glass-panel fill-height">
                    <v-card-title class="headline secondary--text">
                        <v-icon left color="secondary">mdi-cloud-sync</v-icon>
                        Ecosystem Bridge
                    </v-card-title>
                    <v-card-text>
                        <v-alert border="left" colored-border type="info" class="glass-card mb-6" color="secondary">
                            Connect this node to the ProBharath Cloud for Downtime Harvesting.
                        </v-alert>

                        <div class="harvesting-panel pa-4 rounded-lg mb-6" style="background: rgba(144, 202, 249, 0.1);">
                            <div class="d-flex justify-space-between align-center">
                                <div>
                                    <h3 class="subtitle-1 white--text">Downtime Harvesting (AI)</h3>
                                    <span class="caption grey--text">Auto-accept marketplace orders when idle</span>
                                </div>
                                <v-switch color="secondary" input-value="false"></v-switch>
                            </div>
                            <v-slider color="secondary" label="Min Profit" value="5" min="2" max="20" thumb-label="always" class="mt-4"></v-slider>
                        </div>

                        <v-text-field
                            label="Ecosystem Claim Code"
                            value="PBT-FACTORY-MK1"
                            readonly
                            outlined
                            append-icon="mdi-content-copy"
                            class="mt-4"
                        ></v-text-field>
                        
                        <p class="body-2 grey--text">Claim your hardware at <strong>probharath.com/ptc</strong></p>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>
    </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'

@Component
export default class Connectivity extends Vue {
    btEnabled = true
    hotspotEnabled = true
    mcuEnabled = true
    localIp = '127.0.0.1'

    async created() {
        await this.refreshStatus()
    }

    async refreshStatus() {
        try {
            const res = await fetch(`http://${window.location.hostname}:8255/api/status`)
            const data = await res.json()
            this.localIp = data.ip || window.location.hostname
        } catch (e) {
            console.error("Failed to fetch discovery status")
        }
    }

    get qrImageUrl() {
        return `https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=http://${this.localIp}:8255`
    }

    async toggleFeature(feature: string, enabled: boolean) {
        try {
            await fetch(`http://${window.location.hostname}:8255/api/connectivity/toggle`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ feature, enabled })
            })
        } catch (e) {
            console.error(`Failed to toggle ${feature}`)
        }
    }
}
</script>

<style scoped>
.glass-panel {
    background: rgba(255, 255, 255, 0.03) !important;
    backdrop-filter: blur(10px);
    border: 1px solid rgba(255, 255, 255, 0.05);
}
.glass-card {
    background: rgba(255, 255, 255, 0.05);
}
.transparent-list {
    background: transparent !important;
}
</style>
