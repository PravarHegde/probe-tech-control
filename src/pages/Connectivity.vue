<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product - ProConnect & Zero-Config Network Engine
============================================================================== 
-->
<template>
    <div class="connectivity-page pa-2 pa-sm-4">
        <!-- Top Status Banner -->
        <v-card class="glass-panel mb-4 pa-4 rounded-xl">
            <div class="d-flex flex-wrap align-center justify-space-between">
                <div class="d-flex align-center">
                    <v-avatar color="rgba(0, 229, 255, 0.15)" size="48" class="mr-3 border-cyan">
                        <v-icon color="cyan" size="28">{{ currentWifi.connected ? 'mdi-wifi-check' : 'mdi-wifi-alert' }}</v-icon>
                    </v-avatar>
                    <div>
                        <div class="text-caption text-uppercase font-weight-bold cyan--text letter-spacing-1">
                            Active Network Connection
                        </div>
                        <div class="text-h6 font-weight-bold white--text d-flex align-center">
                            {{ currentWifi.ssid || 'ProBharath-Setup (Hotspot)' }}
                            <v-chip x-small color="success" class="ml-2 px-2" v-if="currentWifi.connected">
                                <v-icon x-small left>mdi-check-circle</v-icon> ACTIVE (PRIORITY {{ currentWifi.priority || 1 }})
                            </v-chip>
                            <v-chip x-small color="warning" class="ml-2 px-2" v-else>
                                <v-icon x-small left>mdi-access-point</v-icon> EMERGENCY HOTSPOT
                            </v-chip>
                        </div>
                        <div class="text-caption grey--text text--lighten-1">
                            IP: <span class="cyan--text font-weight-medium">{{ localIp }}</span> &bull; 
                            Host: <span class="white--text font-weight-medium">http://probharath.local:8080</span>
                        </div>
                    </div>
                </div>
                <div class="mt-3 mt-sm-0 d-flex align-center">
                    <v-btn small color="cyan darken-3" class="mr-2 text-none" @click="copyHostUrl">
                        <v-icon left small>mdi-content-copy</v-icon>
                        Copy URL
                    </v-btn>
                    <v-btn small outlined color="cyan" class="text-none" :loading="isScanning" @click="scanWifiNetworks">
                        <v-icon left small :class="{ 'spin-icon': isScanning }">mdi-refresh</v-icon>
                        Scan Nearby Wi-Fi
                    </v-btn>
                </div>
            </div>
        </v-card>

        <v-row>
            <!-- Column 1: Wi-Fi Scanner & Priority Manager -->
            <v-col cols="12" lg="7">
                <!-- Phone-Style Wi-Fi Scanner & Priority Selector -->
                <v-card class="glass-panel mb-4 rounded-xl overflow-hidden">
                    <v-card-title class="d-flex justify-space-between align-center py-3 px-4" style="background: rgba(0, 229, 255, 0.05);">
                        <div class="d-flex align-center">
                            <v-icon left color="cyan">mdi-wifi-star</v-icon>
                            <span class="text-subtitle-1 font-weight-bold white--text">Wi-Fi Networks & Priority Selection</span>
                        </div>
                        <v-btn x-small color="cyan" class="text-none" @click="openAddNetworkModal()">
                            <v-icon left x-small>mdi-plus</v-icon>
                            Add Wi-Fi
                        </v-btn>
                    </v-card-title>
                    <v-divider class="my-0" />
                    
                    <v-card-text class="pa-4">
                        <p class="text-caption grey--text mb-3">
                            Rank your Wi-Fi networks by priority. If your primary shop/home router drops, ProBharath will automatically switch to your Master Pi Farm hotspot or backup Wi-Fi within 20 seconds.
                        </p>

                        <!-- Saved Networks List (Ranked by Priority) -->
                        <div class="subtitle-2 font-weight-bold cyan--text mb-2 d-flex align-center">
                            <v-icon small left color="cyan">mdi-format-list-numbered</v-icon>
                            Saved Wi-Fi Profiles (Ranked Failover)
                        </div>

                        <v-list class="transparent-list pa-0 mb-4" rounded>
                            <v-list-item
                                v-for="(net, idx) in savedNetworks"
                                :key="net.ssid"
                                class="network-item mb-2 rounded-lg"
                                :style="net.active ? 'border-left: 3px solid #00e5ff;' : ''">
                                <v-list-item-avatar size="36" class="my-0 mr-3">
                                    <v-icon :color="net.priority === 1 ? 'amber' : net.priority === 2 ? 'cyan' : 'grey'">
                                        {{ net.priority === 1 ? 'mdi-numeric-1-circle' : net.priority === 2 ? 'mdi-numeric-2-circle' : 'mdi-numeric-3-circle' }}
                                    </v-icon>
                                </v-list-item-avatar>
                                <v-list-item-content>
                                    <v-list-item-title class="white--text font-weight-medium d-flex align-center">
                                        {{ net.ssid }}
                                        <v-chip x-small color="rgba(0, 229, 255, 0.2)" class="cyan--text ml-2 font-weight-bold">
                                            Priority {{ net.priority }}
                                        </v-chip>
                                        <v-chip x-small color="success" class="ml-1" v-if="net.active">
                                            CONNECTED
                                        </v-chip>
                                    </v-list-item-title>
                                    <v-list-item-subtitle class="caption grey--text">
                                        {{ getPriorityDescription(net.priority) }} &bull; {{ net.security || 'WPA2/WPA3' }}
                                    </v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action class="d-flex flex-row align-center my-0">
                                    <v-btn icon x-small class="mr-1" color="cyan" @click="editNetwork(net)">
                                        <v-icon small>mdi-pencil</v-icon>
                                    </v-btn>
                                    <v-btn icon x-small color="error" @click="deleteNetwork(idx)">
                                        <v-icon small>mdi-trash-can-outline</v-icon>
                                    </v-btn>
                                </v-list-item-action>
                            </v-list-item>
                        </v-list>

                        <v-divider class="my-3" />

                        <!-- Available Nearby Wi-Fi (Phone Style List) -->
                        <div class="d-flex justify-space-between align-center mb-2">
                            <div class="subtitle-2 font-weight-bold white--text d-flex align-center">
                                <v-icon small left color="green">mdi-wifi-arrow-up-down</v-icon>
                                Nearby Available Networks (Phone Style)
                            </div>
                            <span class="caption grey--text">{{ scannedNetworks.length }} found</span>
                        </div>

                        <v-sheet max-height="240" class="overflow-y-auto transparent-list pa-0 rounded-lg">
                            <v-list class="transparent-list pa-0" dense>
                                <v-list-item
                                    v-for="wifi in scannedNetworks"
                                    :key="wifi.ssid"
                                    class="nearby-wifi-item py-1 mb-1 rounded cursor-pointer"
                                    @click="selectScannedWifi(wifi)">
                                    <v-list-item-icon class="mr-3 my-auto">
                                        <v-icon :color="getSignalColor(wifi.signal)">{{ getSignalIcon(wifi.signal) }}</v-icon>
                                    </v-list-item-icon>
                                    <v-list-item-content>
                                        <v-list-item-title class="white--text font-weight-medium">
                                            {{ wifi.ssid }}
                                        </v-list-item-title>
                                        <v-list-item-subtitle class="caption grey--text">
                                            Signal: {{ wifi.signal }}% &bull; {{ wifi.security }}
                                        </v-list-item-subtitle>
                                    </v-list-item-content>
                                    <v-list-item-action class="my-auto">
                                        <v-btn x-small rounded color="cyan" class="text-none font-weight-bold">
                                            Connect
                                        </v-btn>
                                    </v-list-item-action>
                                </v-list-item>
                            </v-list>
                        </v-sheet>
                    </v-card-text>
                </v-card>
            </v-col>

            <!-- Column 2: Wi-Fi Failure, Hotspot, BLE & Cloud Bridge -->
            <v-col cols="12" lg="5">
                <!-- Wi-Fi Failure & Emergency Hotspot Settings -->
                <v-card class="glass-panel mb-4 rounded-xl overflow-hidden">
                    <v-card-title class="d-flex align-center py-3 px-4" style="background: rgba(255, 152, 0, 0.08);">
                        <v-icon left color="orange">mdi-wifi-alert</v-icon>
                        <span class="text-subtitle-1 font-weight-bold white--text">Wi-Fi Failure & Emergency Hotspot</span>
                    </v-card-title>
                    <v-divider class="my-0" />
                    <v-card-text class="pa-4">
                        <v-list class="transparent-list pa-0" dense>
                            <!-- Auto Failover Hotspot -->
                            <v-list-item class="pa-0 mb-3">
                                <v-list-item-avatar size="32" color="rgba(255, 152, 0, 0.15)">
                                    <v-icon small color="orange">mdi-access-point-network</v-icon>
                                </v-list-item-avatar>
                                <v-list-item-content>
                                    <v-list-item-title class="white--text font-weight-medium">Emergency Setup Hotspot</v-list-item-title>
                                    <v-list-item-subtitle class="caption grey--text">
                                        Activates if all Wi-Fi networks fail for &gt; 20s
                                    </v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="failoverHotspotEnabled" color="orange" hide-details></v-switch>
                                </v-list-item-action>
                            </v-list-item>

                            <!-- Master Pi Farm Latch -->
                            <v-list-item class="pa-0 mb-3">
                                <v-list-item-avatar size="32" color="rgba(0, 229, 255, 0.15)">
                                    <v-icon small color="cyan">mdi-server-network</v-icon>
                                </v-list-item-avatar>
                                <v-list-item-content>
                                    <v-list-item-title class="white--text font-weight-medium">Master Pi Farm Priority</v-list-item-title>
                                    <v-list-item-subtitle class="caption grey--text">
                                        Auto-link to Master Pi AP in multi-machine farms
                                    </v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="masterPiPriorityEnabled" color="cyan" hide-details></v-switch>
                                </v-list-item-action>
                            </v-list-item>

                            <!-- Bluetooth BLE Beacon -->
                            <v-list-item class="pa-0 mb-3">
                                <v-list-item-avatar size="32" color="rgba(33, 150, 243, 0.15)">
                                    <v-icon small color="blue">mdi-bluetooth</v-icon>
                                </v-list-item-avatar>
                                <v-list-item-content>
                                    <v-list-item-title class="white--text font-weight-medium">Bluetooth BLE URL Beacon</v-list-item-title>
                                    <v-list-item-subtitle class="caption grey--text">
                                        Broadcasts probharath.local nearby to phones
                                    </v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="btBeaconEnabled" color="blue" hide-details></v-switch>
                                </v-list-item-action>
                            </v-list-item>

                            <!-- MCU LCD Branding -->
                            <v-list-item class="pa-0">
                                <v-list-item-avatar size="32" color="rgba(76, 175, 80, 0.15)">
                                    <v-icon small color="success">mdi-monitor-screenshot</v-icon>
                                </v-list-item-avatar>
                                <v-list-item-content>
                                    <v-list-item-title class="white--text font-weight-medium">LCD Screen IP Display</v-list-item-title>
                                    <v-list-item-subtitle class="caption grey--text">
                                        Shows IP on printer 12864 LCD screen
                                    </v-list-item-subtitle>
                                </v-list-item-content>
                                <v-list-item-action>
                                    <v-switch v-model="mcuScreenEnabled" color="success" hide-details></v-switch>
                                </v-list-item-action>
                            </v-list-item>
                        </v-list>

                        <v-divider class="my-3" />

                        <!-- Hotspot Customization Info -->
                        <div class="pa-3 rounded-lg" style="background: rgba(0, 0, 0, 0.25); border: 1px solid rgba(255, 255, 255, 0.05);">
                            <div class="caption font-weight-bold grey--text text--lighten-1 mb-1">
                                FALLBACK HOTSPOT PARAMETERS:
                            </div>
                            <div class="caption cyan--text">
                                SSID: <strong>ProBharath-Setup-{{ macSuffix }}</strong>
                            </div>
                            <div class="caption grey--text">
                                Access Point IP: <strong>192.168.4.1</strong> (or <strong>http://probharath.local</strong>)
                            </div>
                        </div>
                    </v-card-text>
                </v-card>

                <!-- Cloud Bridge & Ecosystem Claim Card -->
                <v-card class="glass-panel rounded-xl overflow-hidden">
                    <v-card-title class="d-flex align-center py-3 px-4" style="background: rgba(156, 39, 176, 0.08);">
                        <v-icon left color="purple">mdi-cloud-sync</v-icon>
                        <span class="text-subtitle-1 font-weight-bold white--text">ProConnect Ecosystem Bridge</span>
                    </v-card-title>
                    <v-divider class="my-0" />
                    <v-card-text class="pa-4">
                        <div class="pa-3 rounded-lg mb-3" style="background: rgba(156, 39, 176, 0.12); border: 1px solid rgba(156, 39, 176, 0.3);">
                            <div class="d-flex justify-space-between align-center">
                                <div>
                                    <div class="subtitle-2 font-weight-bold white--text">Downtime Harvesting (AI)</div>
                                    <div class="caption grey--text">Auto-accept network print orders when idle</div>
                                </div>
                                <v-switch v-model="downtimeHarvesting" color="purple" hide-details class="mt-0"></v-switch>
                            </div>
                            <v-slider
                                v-model="minProfit"
                                color="purple"
                                label="Min Profit ($)"
                                min="2"
                                max="25"
                                thumb-label="always"
                                class="mt-4"
                                hide-details>
                            </v-slider>
                        </div>

                        <v-text-field
                            label="Ecosystem Claim Code"
                            :value="claimCode"
                            readonly
                            outlined
                            dense
                            color="purple"
                            append-icon="mdi-content-copy"
                            @click:append="copyClaimCode"
                            class="mb-1"
                        ></v-text-field>
                        <div class="caption grey--text text-center">
                            Attach printer to cloud at <strong class="cyan--text">probharath.com/proconnect</strong>
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>

        <!-- Connect / Edit Wi-Fi Dialog -->
        <v-dialog v-model="wifiDialog" max-width="440">
            <v-card class="glass-panel rounded-xl pa-2">
                <v-card-title class="headline cyan--text pb-1">
                    <v-icon left color="cyan">mdi-wifi-lock</v-icon>
                    {{ isEditing ? 'Edit Wi-Fi Profile' : 'Connect to Wi-Fi' }}
                </v-card-title>
                <v-card-text class="pt-2">
                    <v-text-field
                        v-model="dialogSsid"
                        label="Network SSID"
                        outlined
                        dense
                        color="cyan"
                        prepend-inner-icon="mdi-wifi"
                        class="mb-2"
                    ></v-text-field>

                    <v-text-field
                        v-model="dialogPassword"
                        label="Wi-Fi Password"
                        :type="showPassword ? 'text' : 'password'"
                        outlined
                        dense
                        color="cyan"
                        prepend-inner-icon="mdi-lock"
                        :append-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
                        @click:append="showPassword = !showPassword"
                        class="mb-2"
                        placeholder="Leave blank for open networks"
                    ></v-text-field>

                    <div class="subtitle-2 font-weight-bold white--text mb-1">Failover Priority:</div>
                    <v-select
                        v-model="dialogPriority"
                        :items="priorityOptions"
                        outlined
                        dense
                        color="cyan"
                        item-text="text"
                        item-value="value"
                        class="mb-1"
                    ></v-select>
                    <div class="caption grey--text">
                        Priority 1 is attempted first. If disconnected for &gt; 20s, it auto-switches to Priority 2.
                    </div>
                </v-card-text>
                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn text color="grey lighten-1" @click="wifiDialog = false">Cancel</v-btn>
                    <v-btn color="cyan" class="font-weight-bold px-4" @click="saveWifiNetwork">
                        Save &amp; Connect
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Snackbar Notification -->
        <v-snackbar v-model="snackbar" :color="snackbarColor" timeout="2500" top>
            {{ snackbarText }}
        </v-snackbar>
    </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'

interface WifiNetwork {
    ssid: string
    priority: number
    password?: string
    security?: string
    active?: boolean
    signal?: number
}

@Component
export default class Connectivity extends Vue {
    localIp = '192.168.1.19'
    macSuffix = '4A19'
    claimCode = 'PBT-FACTORY-MK1'

    // Status toggles
    failoverHotspotEnabled = true
    masterPiPriorityEnabled = true
    btBeaconEnabled = true
    mcuScreenEnabled = true
    downtimeHarvesting = false
    minProfit = 5

    // Wi-Fi Scanning & Profiles
    isScanning = false
    wifiDialog = false
    isEditing = false
    showPassword = false
    dialogSsid = ''
    dialogPassword = ''
    dialogPriority = 1

    snackbar = false
    snackbarText = ''
    snackbarColor = 'success'

    priorityOptions = [
        { text: 'Priority 1 (Primary Home / Workshop Router)', value: 1 },
        { text: 'Priority 2 (Master Pi Farm Hotspot)', value: 2 },
        { text: 'Priority 3 (Mobile Phone Hotspot / Backup)', value: 3 },
    ]

    savedNetworks: WifiNetwork[] = [
        { ssid: 'ProBharath-Lab-5G', priority: 1, security: 'WPA2/WPA3', active: true },
        { ssid: 'ProBharath-MasterPi-Farm', priority: 2, security: 'WPA2', active: false },
        { ssid: 'Founder-Mobile-Hotspot', priority: 3, security: 'WPA2', active: false },
    ]

    scannedNetworks: WifiNetwork[] = [
        { ssid: 'ProBharath-Lab-5G', signal: 94, security: 'WPA2/WPA3' },
        { ssid: 'ProBharath-MasterPi-Farm', signal: 82, security: 'WPA2' },
        { ssid: 'Airtel_Fiber_5GHz', signal: 68, security: 'WPA2' },
        { ssid: 'JioFiber-Workshop', signal: 55, security: 'WPA2' },
        { ssid: 'MakerSpace_Guest', signal: 42, security: 'Open' },
    ]

    get currentWifi(): WifiNetwork {
        return this.savedNetworks.find((n) => n.active) || { ssid: 'ProBharath-Lab-5G', priority: 1, connected: true }
    }

    mounted() {
        this.localIp = window.location.hostname || '192.168.1.19'
        this.loadSavedProfiles()
    }

    loadSavedProfiles() {
        const stored = localStorage.getItem('probharath_wifi_profiles')
        if (stored) {
            try {
                this.savedNetworks = JSON.parse(stored)
            } catch (e) {
                // Keep defaults
            }
        }
    }

    saveProfilesToStorage() {
        localStorage.setItem('probharath_wifi_profiles', JSON.stringify(this.savedNetworks))
    }

    getPriorityDescription(priority: number) {
        if (priority === 1) return 'Primary Router (Attempted 1st)'
        if (priority === 2) return 'Master Pi Farm Hotspot (Failover 2nd)'
        return 'Mobile Hotspot / Backup (Failover 3rd)'
    }

    getSignalIcon(signal = 50) {
        if (signal >= 75) return 'mdi-wifi-strength-4'
        if (signal >= 50) return 'mdi-wifi-strength-3'
        if (signal >= 25) return 'mdi-wifi-strength-2'
        return 'mdi-wifi-strength-1'
    }

    getSignalColor(signal = 50) {
        if (signal >= 75) return 'green lighten-1'
        if (signal >= 50) return 'cyan lighten-1'
        if (signal >= 25) return 'amber'
        return 'grey'
    }

    scanWifiNetworks() {
        this.isScanning = true
        setTimeout(() => {
            this.isScanning = false
            this.showToast('Wi-Fi scan complete. Found 5 networks.', 'cyan')
        }, 1200)
    }

    openAddNetworkModal() {
        this.isEditing = false
        this.dialogSsid = ''
        this.dialogPassword = ''
        this.dialogPriority = this.savedNetworks.length + 1 <= 3 ? this.savedNetworks.length + 1 : 3
        this.showPassword = false
        this.wifiDialog = true
    }

    selectScannedWifi(wifi: WifiNetwork) {
        this.isEditing = false
        this.dialogSsid = wifi.ssid
        this.dialogPassword = ''
        this.dialogPriority = 1
        this.showPassword = false
        this.wifiDialog = true
    }

    editNetwork(net: WifiNetwork) {
        this.isEditing = true
        this.dialogSsid = net.ssid
        this.dialogPassword = net.password || ''
        this.dialogPriority = net.priority
        this.showPassword = false
        this.wifiDialog = true
    }

    saveWifiNetwork() {
        if (!this.dialogSsid.trim()) {
            this.showToast('Please enter an SSID', 'error')
            return
        }

        const existingIdx = this.savedNetworks.findIndex((n) => n.ssid === this.dialogSsid)
        if (existingIdx !== -1) {
            this.savedNetworks[existingIdx].priority = this.dialogPriority
            this.savedNetworks[existingIdx].password = this.dialogPassword
        } else {
            this.savedNetworks.push({
                ssid: this.dialogSsid,
                priority: this.dialogPriority,
                password: this.dialogPassword,
                security: this.dialogPassword ? 'WPA2' : 'Open',
                active: false,
            })
        }

        // Sort by priority (1 first)
        this.savedNetworks.sort((a, b) => a.priority - b.priority)
        this.saveProfilesToStorage()

        this.wifiDialog = false
        this.showToast(`Saved Wi-Fi '${this.dialogSsid}' at Priority ${this.dialogPriority}`, 'success')
    }

    deleteNetwork(idx: number) {
        const deleted = this.savedNetworks.splice(idx, 1)
        this.saveProfilesToStorage()
        if (deleted.length > 0) {
            this.showToast(`Removed Wi-Fi profile '${deleted[0].ssid}'`, 'info')
        }
    }

    copyHostUrl() {
        navigator.clipboard.writeText(`http://${this.localIp}:8080`)
        this.showToast('Copied URL to clipboard: http://' + this.localIp + ':8080', 'cyan')
    }

    copyClaimCode() {
        navigator.clipboard.writeText(this.claimCode)
        this.showToast('Copied Claim Code: ' + this.claimCode, 'purple')
    }

    showToast(msg: string, color = 'success') {
        this.snackbarText = msg
        this.snackbarColor = color
        this.snackbar = true
    }
}
</script>

<style scoped>
.glass-panel {
    background: rgba(13, 25, 48, 0.75) !important;
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid rgba(0, 229, 255, 0.18) !important;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
}

.border-cyan {
    border: 1px solid rgba(0, 229, 255, 0.4);
}

.letter-spacing-1 {
    letter-spacing: 1px;
}

.transparent-list {
    background: transparent !important;
}

.network-item {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    transition: all 0.2s ease;
}

.network-item:hover {
    background: rgba(0, 229, 255, 0.08);
    border-color: rgba(0, 229, 255, 0.3);
}

.nearby-wifi-item {
    background: rgba(255, 255, 255, 0.02);
    border: 1px solid rgba(255, 255, 255, 0.05);
    transition: background 0.2s ease;
}

.nearby-wifi-item:hover {
    background: rgba(0, 229, 255, 0.1);
}

.spin-icon {
    animation: spin 1s linear infinite;
}

@keyframes spin {
    100% {
        transform: rotate(360deg);
    }
}
</style>
