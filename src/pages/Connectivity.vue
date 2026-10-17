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

                        <!-- Empty State if no saved profiles -->
                        <div v-if="savedNetworks.length === 0" class="text-center py-4 my-2 rounded-lg" style="background: rgba(255,255,255,0.02); border: 1px dashed rgba(0,229,255,0.2);">
                            <v-icon color="grey lighten-1" class="mb-1">mdi-wifi-off</v-icon>
                            <div class="caption grey--text">No saved Wi-Fi profiles found.</div>
                            <div class="caption cyan--text mt-1">Select a network from nearby below or click "+ Add Wi-Fi".</div>
                        </div>

                        <v-list v-else class="transparent-list pa-0 mb-4" rounded>
                            <v-list-item
                                v-for="(net, idx) in savedNetworks"
                                :key="net.name || net.ssid"
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
                            <div v-if="scannedNetworks.length === 0" class="text-center py-6 grey--text caption">
                                <v-progress-circular v-if="isScanning" indeterminate size="24" color="cyan" class="mb-2"></v-progress-circular>
                                <div>{{ isScanning ? 'Scanning nearby Wi-Fi via nmcli...' : 'No networks detected. Click "Scan Nearby Wi-Fi" above.' }}</div>
                            </div>
                            <v-list v-else class="transparent-list pa-0" dense>
                                <v-list-item
                                    v-for="wifi in scannedNetworks"
                                    :key="wifi.ssid"
                                    class="nearby-wifi-item py-1 mb-1 rounded cursor-pointer"
                                    @click="selectScannedWifi(wifi)">
                                    <v-list-item-icon class="mr-3 my-auto">
                                        <v-icon :color="getSignalColor(wifi.signal)">{{ getSignalIcon(wifi.signal) }}</v-icon>
                                    </v-list-item-icon>
                                    <v-list-item-content>
                                        <v-list-item-title class="white--text font-weight-medium d-flex align-center">
                                            {{ wifi.ssid }}
                                            <v-chip v-if="wifi.active" x-small color="success" class="ml-2 font-weight-bold">CONNECTED</v-chip>
                                        </v-list-item-title>
                                        <v-list-item-subtitle class="caption grey--text">
                                            Signal: {{ wifi.signal }}% &bull; {{ wifi.security }}
                                        </v-list-item-subtitle>
                                    </v-list-item-content>
                                    <v-list-item-action class="my-auto">
                                        <v-btn x-small rounded color="cyan" class="text-none font-weight-bold" @click.stop="selectScannedWifi(wifi)">
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
                                    <v-switch v-model="failoverHotspotEnabled" color="orange" hide-details @change="toggleHotspot"></v-switch>
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
                                    <v-switch v-model="btBeaconEnabled" color="blue" hide-details @change="toggleBeacon"></v-switch>
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

                        <!-- Hotspot Customization Info Sector -->
                        <div class="pa-3 rounded-lg" style="background: rgba(0, 0, 0, 0.25); border: 1px solid rgba(255, 255, 255, 0.05);">
                            <div class="d-flex justify-space-between align-center mb-1">
                                <div class="caption font-weight-bold grey--text text--lighten-1">
                                    HOTSPOT CONFIGURATION SECTOR:
                                </div>
                                <v-btn x-small text color="cyan" class="px-1 text-none" @click="openHotspotConfig">
                                    <v-icon x-small left>mdi-cog</v-icon> Configure
                                </v-btn>
                            </div>
                            <div class="caption cyan--text">
                                SSID: <strong>{{ customHotspotSsid || `ProBharath-Setup-${macSuffix}` }}</strong>
                                <v-chip x-small class="ml-1 px-1 font-weight-bold" :color="hotspotPassword ? 'purple' : 'teal'">
                                    {{ hotspotPassword ? 'WPA2 SECURED' : 'OPEN (1-TAP ONBOARD)' }}
                                </v-chip>
                            </div>
                            <div class="caption grey--text">
                                Access Point IP: <strong>192.168.4.1</strong> (or <strong>http://probharath.local</strong>)
                            </div>
                            <div class="caption grey--text" v-if="hotspotPassword">
                                Password: <strong class="white--text">{{ hotspotPassword }}</strong>
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
                    <v-btn text color="grey lighten-1" :disabled="isConnecting" @click="wifiDialog = false">Cancel</v-btn>
                    <v-btn color="cyan" class="font-weight-bold px-4" :loading="isConnecting" :disabled="isConnecting" @click="saveWifiNetwork">
                        Save &amp; Connect
                    </v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Hotspot Configuration Dialog -->
        <v-dialog v-model="hotspotConfigDialog" max-width="420">
            <v-card class="glass-panel rounded-xl pa-2">
                <v-card-title class="headline orange--text pb-1">
                    <v-icon left color="orange">mdi-access-point</v-icon>
                    Hotspot Settings
                </v-card-title>
                <v-card-text class="pt-2">
                    <p class="caption grey--text mb-3">
                        Configure emergency fallback hotspot SSID and security. Leave password blank for Open (1-Tap onboarding).
                    </p>
                    <v-text-field
                        v-model="tempHotspotSsid"
                        label="Hotspot SSID"
                        outlined
                        dense
                        color="orange"
                        prepend-inner-icon="mdi-wifi"
                        class="mb-2"
                    ></v-text-field>
                    <v-text-field
                        v-model="tempHotspotPassword"
                        label="Hotspot Password (Optional)"
                        :type="showHotspotPassword ? 'text' : 'password'"
                        outlined
                        dense
                        color="orange"
                        prepend-inner-icon="mdi-lock"
                        :append-icon="showHotspotPassword ? 'mdi-eye-off' : 'mdi-eye'"
                        @click:append="showHotspotPassword = !showHotspotPassword"
                        class="mb-2"
                        placeholder="Leave blank for Open (Recommended)"
                        hint="Minimum 8 characters if setting a password"
                        persistent-hint
                    ></v-text-field>
                </v-card-text>
                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn text color="grey lighten-1" @click="hotspotConfigDialog = false">Cancel</v-btn>
                    <v-btn color="orange darken-1" class="font-weight-bold white--text px-4" @click="saveHotspotConfig">
                        Save Hotspot
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
    name?: string
    ssid: string
    priority: number
    password?: string
    security?: string
    active?: boolean
    connected?: boolean
    signal?: number
}

@Component
export default class Connectivity extends Vue {
    localIp = window.location.hostname || '192.168.1.19'
    macSuffix = 'E2F1'
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
    isConnecting = false
    wifiDialog = false
    isEditing = false
    showPassword = false
    dialogSsid = ''
    dialogPassword = ''
    dialogPriority = 1

    // Hotspot Configuration Sector
    hotspotConfigDialog = false
    customHotspotSsid = ''
    hotspotPassword = ''
    tempHotspotSsid = ''
    tempHotspotPassword = ''
    showHotspotPassword = false

    snackbar = false
    snackbarText = ''
    snackbarColor = 'success'

    currentNetwork: any = {
        ssid: '',
        connected: false,
        signal: 0,
        priority: 1
    }

    savedNetworks: WifiNetwork[] = []
    scannedNetworks: WifiNetwork[] = []
    pollTimer: any = null

    priorityOptions = [
        { text: 'Priority 1 (Primary Home / Workshop Router)', value: 1 },
        { text: 'Priority 2 (Master Pi Farm Hotspot)', value: 2 },
        { text: 'Priority 3 (Mobile Phone Hotspot / Backup)', value: 3 },
    ]

    get currentWifi(): WifiNetwork {
        if (this.currentNetwork.connected && this.currentNetwork.ssid) {
            const saved = this.savedNetworks.find((n) => n.ssid === this.currentNetwork.ssid)
            return {
                ssid: this.currentNetwork.ssid,
                connected: true,
                priority: saved ? saved.priority : 1,
                signal: this.currentNetwork.signal,
                security: saved ? saved.security : 'WPA2/WPA3'
            }
        }
        const activeSaved = this.savedNetworks.find((n) => n.active)
        if (activeSaved) {
            return {
                ...activeSaved,
                connected: true
            }
        }
        return {
            ssid: '',
            connected: false,
            priority: 1
        }
    }

    async mounted() {
        this.localIp = window.location.hostname || '192.168.1.19'
        const savedSsid = localStorage.getItem('probharath_hotspot_ssid')
        if (savedSsid) this.customHotspotSsid = savedSsid
        const savedPw = localStorage.getItem('probharath_hotspot_pw')
        if (savedPw) this.hotspotPassword = savedPw
        await Promise.all([
            this.fetchNetworkStatus(),
            this.fetchSavedNetworks(),
            this.scanWifiNetworks()
        ])

        // Live polling every 7 seconds
        this.pollTimer = setInterval(() => {
            this.fetchNetworkStatus()
        }, 7000)
    }

    beforeDestroy() {
        if (this.pollTimer) {
            clearInterval(this.pollTimer)
            this.pollTimer = null
        }
    }

    async fetchNetworkStatus() {
        try {
            const res = await fetch('/api/network/status')
            if (res.ok) {
                const data = await res.json()
                if (data) {
                    if (data.ip) this.localIp = data.ip
                    if (data.mac_suffix) this.macSuffix = data.mac_suffix
                    this.currentNetwork = {
                        ssid: data.ssid || '',
                        connected: !!data.connected,
                        signal: data.signal || 0,
                        priority: 1
                    }
                }
            }
        } catch (e) {
            // Fail silently on poll
        }
    }

    async fetchSavedNetworks() {
        try {
            const res = await fetch('/api/network/saved')
            if (res.ok) {
                const data = await res.json()
                if (data.saved) {
                    this.savedNetworks = data.saved
                }
            }
        } catch (e) {
            console.error('Failed to load saved networks:', e)
        }
    }

    async scanWifiNetworks() {
        this.isScanning = true
        try {
            const res = await fetch('/api/network/scan')
            if (res.ok) {
                const data = await res.json()
                if (data.networks && data.networks.length > 0) {
                    this.scannedNetworks = data.networks
                    this.showToast(`Wi-Fi scan complete. Found ${data.networks.length} live networks.`, 'cyan')
                } else {
                    this.showToast('No nearby Wi-Fi networks found.', 'warning')
                }
            }
        } catch (e: any) {
            this.showToast('Error scanning Wi-Fi: ' + (e.message || e), 'error')
        } finally {
            this.isScanning = false
        }
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

    async saveWifiNetwork() {
        if (!this.dialogSsid.trim()) {
            this.showToast('Please enter an SSID', 'error')
            return
        }

        const ssid = this.dialogSsid.trim()
        const password = this.dialogPassword
        const priority = this.dialogPriority

        this.isConnecting = true
        try {
            const res = await fetch('/api/network/connect', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ ssid, password, priority })
            })
            const data = await res.json()
            if (data.success) {
                this.showToast(data.message || `Saved '${ssid}' at Priority ${priority}`, data.connected ? 'success' : 'info')
                this.wifiDialog = false
                // Refresh data from Pi
                setTimeout(() => {
                    this.fetchNetworkStatus()
                    this.fetchSavedNetworks()
                    this.scanWifiNetworks()
                }, 2000)
            } else {
                this.showToast(`Failed: ${data.message || 'Unknown error'}`, 'error')
            }
        } catch (e: any) {
            this.showToast('Error saving network: ' + (e.message || e), 'error')
        } finally {
            this.isConnecting = false
        }
    }

    async deleteNetwork(idx: number) {
        const net = this.savedNetworks[idx]
        if (!net) return
        try {
            const res = await fetch('/api/network/delete', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ name: net.name || net.ssid })
            })
            const data = await res.json()
            if (data.success) {
                this.showToast(`Removed Wi-Fi profile '${net.ssid}'`, 'info')
                this.savedNetworks.splice(idx, 1)
                this.fetchSavedNetworks()
                this.fetchNetworkStatus()
            }
        } catch (e) {
            this.showToast('Failed to delete network profile', 'error')
        }
    }

    async toggleHotspot(enabled: boolean) {
        try {
            const res = await fetch('/api/network/hotspot', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ enabled })
            })
            const data = await res.json()
            if (data.success) {
                this.showToast(enabled ? 'Emergency Hotspot enabled!' : 'Emergency Hotspot disabled.', enabled ? 'warning' : 'info')
            }
        } catch (e) {
            this.showToast('Failed to toggle hotspot state', 'error')
        }
    }

    openHotspotConfig() {
        this.tempHotspotSsid = this.customHotspotSsid || `ProBharath-Setup-${this.macSuffix}`
        this.tempHotspotPassword = this.hotspotPassword
        this.hotspotConfigDialog = true
    }

    async saveHotspotConfig() {
        try {
            const res = await fetch('/api/network/hotspot/config', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    ssid: this.tempHotspotSsid.trim(),
                    password: this.tempHotspotPassword.trim()
                })
            })
            const data = await res.json()
            if (data.success) {
                this.customHotspotSsid = this.tempHotspotSsid.trim()
                this.hotspotPassword = this.tempHotspotPassword.trim()
                localStorage.setItem('probharath_hotspot_ssid', this.customHotspotSsid)
                localStorage.setItem('probharath_hotspot_pw', this.hotspotPassword)
                this.hotspotConfigDialog = false
                this.showToast(`Hotspot configuration saved: ${this.customHotspotSsid}`, 'orange')
            }
        } catch (e: any) {
            this.showToast('Failed to save hotspot config: ' + e.message, 'error')
        }
    }

    async toggleBeacon(enabled: boolean) {
        try {
            const res = await fetch('/api/network/beacon', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ enabled })
            })
            const data = await res.json()
            if (data.success) {
                this.showToast(enabled ? 'Bluetooth BLE URL Beacon broadcasting active!' : 'Bluetooth BLE Beacon stopped.', 'blue')
            }
        } catch (e) {
            this.showToast('Failed to toggle Bluetooth beacon', 'error')
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
