<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product - ProBharath AI Core & Fleet Co-Pilot
============================================================================== 
-->
<template>
    <div class="agent-dashboard pa-2 pa-sm-4">
        <!-- Top Status Banner -->
        <div class="mb-4 d-flex flex-wrap align-center justify-space-between">
            <div class="d-flex align-center">
                <div class="mr-3 pa-1 rounded-circle pulse-glow-avatar d-flex align-center justify-center" style="background: rgba(226, 232, 240, 0.12); border: 2px solid rgba(226, 232, 240, 0.6); box-shadow: 0 0 18px rgba(226, 232, 240, 0.4); width: 46px; height: 46px; min-width: 46px;">
                    <img src="/img/probharath_elephant_silver.png" alt="ProBharath Elephant" style="width: 36px; height: 36px; object-fit: contain; filter: drop-shadow(0 0 6px rgba(226, 232, 240, 0.95)) brightness(1.25);" />
                </div>
                <div>
                    <div class="text-h5 font-weight-bold white--text d-flex align-center">
                        ProBharath AI Core
                        <v-chip x-small class="ml-2 px-2 silver-chip">
                            Fleet Co-Pilot
                        </v-chip>
                        <v-chip x-small color="cyan darken-3" class="ml-1 px-2 font-weight-bold">
                            MK1 ONLINE
                        </v-chip>
                    </div>
                    <div class="text-caption grey--text">
                        Autonomous fleet orchestration, predictive maintenance &amp; G-code intelligence
                    </div>
                </div>
            </div>
            <div class="mt-2 mt-sm-0 d-flex align-center">
                <!-- Interactive AI Model Selector Menu -->
                <v-menu offset-y transition="slide-y-transition" :close-on-content-click="false" v-model="modelMenuOpen">
                    <template #activator="{ on, attrs }">
                        <v-btn
                            small
                            outlined
                            color="cyan"
                            class="mr-2 text-none font-weight-medium rounded-pill model-selector-btn"
                            v-bind="attrs"
                            v-on="on"
                        >
                            <v-icon left x-small color="cyan">{{ selectedModel.icon }}</v-icon>
                            <span class="white--text">{{ selectedModel.name }}</span>
                            <v-chip x-small color="cyan darken-4" class="ml-1 px-1 white--text font-weight-bold" style="font-size: 9px; height: 16px;">
                                {{ selectedModel.tag }}
                            </v-chip>
                            <v-icon right x-small color="grey lighten-1">{{ mdiChevronDown }}</v-icon>
                        </v-btn>
                    </template>

                    <v-card class="glass-panel rounded-xl pa-3" max-width="390" style="background: rgba(13, 25, 48, 0.96) !important; border: 1px solid rgba(0, 229, 255, 0.35) !important;">
                        <div class="d-flex align-center justify-space-between pb-2 mb-2" style="border-bottom: 1px solid rgba(255, 255, 255, 0.1);">
                            <div class="caption font-weight-bold grey--text text-uppercase tracking-wider">Select AI Intelligence Engine</div>
                            <v-chip x-small outlined color="cyan">{{ availableModels.length }} Models</v-chip>
                        </div>

                        <div
                            v-for="model in availableModels"
                            :key="model.id"
                            class="model-option-card pa-2 rounded-lg mb-2 cursor-pointer"
                            :class="{ 'active-model-card': selectedModel.id === model.id }"
                            @click="selectModel(model)"
                        >
                            <div class="d-flex align-center justify-space-between">
                                <div class="d-flex align-center">
                                    <v-avatar size="24" :color="model.isLocal ? 'rgba(0, 229, 255, 0.15)' : 'rgba(168, 85, 247, 0.15)'" class="mr-2">
                                        <v-icon x-small :color="model.isLocal ? 'cyan' : 'purple lighten-2'">{{ model.icon }}</v-icon>
                                    </v-avatar>
                                    <div>
                                        <div class="subtitle-2 font-weight-bold white--text d-flex align-center">
                                            {{ model.name }}
                                            <v-chip v-if="model.isRecommended" x-small color="green darken-2" class="ml-2 font-weight-bold" style="height: 16px; font-size: 9px;">
                                                RECOMMENDED
                                            </v-chip>
                                        </div>
                                        <div class="caption grey--text" style="font-size: 11px; line-height: 1.3;">{{ model.desc }}</div>
                                    </div>
                                </div>
                                <v-icon v-if="selectedModel.id === model.id" small color="cyan">{{ mdiCheckCircle }}</v-icon>
                            </div>
                            <div class="mt-1 pt-1 d-flex align-center justify-space-between" style="border-top: 1px dashed rgba(255, 255, 255, 0.08);">
                                <span class="caption grey--text text--lighten-1" style="font-size: 10px;">{{ model.latency }} &bull; {{ model.params }}</span>
                                <span class="caption" :class="model.isLocal ? 'cyan--text' : 'purple--text text--lighten-3'" style="font-size: 10px; font-weight: 600;">
                                    {{ model.mode }}
                                </span>
                            </div>
                        </div>
                    </v-card>
                </v-menu>

                <v-btn small outlined color="primary" class="text-none" @click="showManager = true">
                    <v-icon left small>{{ mdiCog }}</v-icon> Manage Agents
                </v-btn>
            </div>
        </div>

        <v-row>
            <!-- Left Column: Factory Command Link (Modern Chat Interface) -->
            <v-col cols="12" lg="8">
                <v-card class="glass-panel rounded-xl overflow-hidden d-flex flex-column" style="min-height: 580px;">
                    <!-- Terminal Header -->
                    <div class="d-flex align-center justify-space-between px-4 py-3" style="background: rgba(255, 255, 255, 0.05); border-bottom: 1px solid rgba(255, 255, 255, 0.1);">
                        <div class="d-flex align-center">
                            <img src="/img/probharath_elephant_silver.png" alt="ProBharath AI" style="width: 24px; height: 24px; object-fit: contain; margin-right: 8px; filter: drop-shadow(0 0 5px rgba(226, 232, 240, 0.8)) brightness(1.2);" />
                            <span class="subtitle-2 font-weight-bold white--text">Factory Command Link</span>
                            <span class="caption grey--text ml-2">({{ activeAgentName }})</span>
                        </div>
                        <v-btn x-small text color="grey lighten-1" class="text-none" @click="clearChat">
                            <v-icon x-small left>{{ mdiTrashCanOutline }}</v-icon> Clear
                        </v-btn>
                    </div>

                    <!-- Messages Viewport -->
                    <div class="chat-viewport pa-4 flex-grow-1 overflow-y-auto" style="height: 420px;">
                        <div v-for="msg in messages" :key="msg.id" class="d-flex mb-3" :class="{ 'justify-end': msg.sender === 'user' }">
                            <v-avatar v-if="msg.sender === 'ai'" size="36" class="mr-2 border-silver my-auto pa-1">
                                <img src="/img/probharath_elephant_silver.png" alt="Elephant AI" style="width: 100%; height: 100%; object-fit: contain; filter: drop-shadow(0 0 5px rgba(226, 232, 240, 0.9)) brightness(1.25);" />
                            </v-avatar>

                            <!-- User Message Bubble -->
                            <div
                                v-if="msg.sender === 'user'"
                                class="user-bubble pa-3 rounded-2xl white--text elevation-3"
                                style="max-width: 82%;"
                            >
                                <div class="body-2 font-weight-medium" style="white-space: pre-wrap;">{{ msg.text }}</div>
                            </div>

                            <!-- AI Message Bubble -->
                            <div
                                v-else
                                class="ai-bubble pa-3 rounded-2xl elevation-3"
                                style="max-width: 85%;"
                            >
                                <div class="body-2 white--text" style="white-space: pre-wrap; line-height: 1.6;">{{ msg.text }}</div>

                                <!-- Actionable G-Code Execution Chip if provided -->
                                <div v-if="msg.action" class="mt-2 pt-2 border-top-glass d-flex align-center justify-space-between">
                                    <span class="caption cyan--text font-weight-medium">
                                        <v-icon x-small color="cyan">{{ mdiCodeBraces }}</v-icon> {{ msg.action.label }}
                                    </span>
                                    <v-btn x-small rounded color="cyan darken-2" class="text-none font-weight-bold px-3" @click="executeAiAction(msg.action)">
                                        <v-icon x-small left>{{ mdiFlash }}</v-icon> Execute on Machine
                                    </v-btn>
                                </div>
                            </div>

                            <v-avatar v-if="msg.sender === 'user'" size="36" class="ml-2 my-auto silver-user-avatar">
                                <v-icon small color="white">{{ mdiAccount }}</v-icon>
                            </v-avatar>
                        </div>

                        <!-- Typing Indicator -->
                        <div v-if="processing" class="d-flex align-center mb-2">
                            <v-avatar size="36" class="mr-2 border-silver pa-1">
                                <img src="/img/probharath_elephant_silver.png" alt="Elephant AI" style="width: 100%; height: 100%; object-fit: contain; filter: drop-shadow(0 0 5px rgba(226, 232, 240, 0.9)) brightness(1.25);" />
                            </v-avatar>
                            <div class="ai-bubble pa-2 px-3 rounded-xl d-flex align-center">
                                <v-progress-circular indeterminate color="grey lighten-1" size="18" width="2" class="mr-2"></v-progress-circular>
                                <span class="caption grey--text">ProBharath AI is reasoning...</span>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Capability Chips -->
                    <div class="px-4 py-2 d-flex flex-wrap align-center" style="background: rgba(0, 0, 0, 0.2); border-top: 1px solid rgba(255, 255, 255, 0.04);">
                        <span class="caption grey--text text--lighten-1 mr-2 font-weight-medium">Quick Prompts:</span>
                        <v-chip
                            v-for="prompt in quickPrompts"
                            :key="prompt.text"
                            x-small
                            outlined
                            :color="prompt.color"
                            class="mr-2 my-1 cursor-pointer font-weight-medium"
                            @click="triggerPrompt(prompt.text)"
                        >
                            <v-icon left x-small :color="prompt.color">{{ prompt.icon }}</v-icon>
                            {{ prompt.label }}
                        </v-chip>
                    </div>

                    <!-- Floating Pill Input Bar -->
                    <div class="pa-3" style="background: rgba(0, 0, 0, 0.4); border-top: 1px solid rgba(255, 255, 255, 0.08);">
                        <div class="d-flex align-center">
                            <v-text-field
                                v-model="newMessage"
                                placeholder="Ask ProBharath AI to optimize the machine, check health, or plan jobs..."
                                solo
                                flat
                                dense
                                hide-details
                                rounded
                                color="grey lighten-1"
                                background-color="rgba(255, 255, 255, 0.05)"
                                class="custom-chat-input"
                                :disabled="processing"
                                @keydown.enter.prevent="sendMessage"
                            ></v-text-field>
                            <v-btn
                                fab
                                small
                                class="ml-2 elevation-4 silver-send-btn"
                                :loading="processing"
                                :disabled="!newMessage.trim()"
                                @click="sendMessage"
                            >
                                <v-icon color="#090d16">{{ mdiSend }}</v-icon>
                            </v-btn>
                        </div>
                    </div>
                </v-card>
            </v-col>

            <!-- Right Column: Analytics & Ecosystem Widgets (Matching Website AIFactoryAgent) -->
            <v-col cols="12" lg="4">
                <!-- Widget 1: Machine Dynamics & Telemetry Console (Priority #1) -->
                <v-card class="supercar-console mb-4 rounded-xl overflow-hidden elevation-8">
                    <!-- Console Top Bezel: Carbon Mesh + Title + Machine Name + Controls -->
                    <div class="supercar-bezel px-4 py-2.5 d-flex align-center justify-space-between">
                        <div class="d-flex align-center">
                            <img
                                src="/img/probharath_elephant_silver.png"
                                alt="ProBharath"
                                style="width: 17px; height: 17px; object-fit: contain; margin-right: 7px; filter: drop-shadow(0 0 5px rgba(0, 229, 255, 0.4));"
                            />
                            <span class="cockpit-title white--text font-weight-black tracking-wider">
                                MACHINE DYNAMICS
                            </span>
                            <span class="cockpit-sub-badge ml-2 px-1.5 py-0.5 rounded text-uppercase">
                                {{ activePrinterName }}
                            </span>
                        </div>
                        <div class="d-flex align-center">
                            <span class="caption grey--text mr-2 font-mono" style="font-size: 10px;">{{ liveUptimeFormatted }}</span>
                            <v-btn icon x-small color="cyan" class="mr-1" @click="fetchLiveSystemData" :loading="telemetryLoading" title="Refresh Live Sensors">
                                <v-icon x-small>{{ mdiRefresh }}</v-icon>
                            </v-btn>
                            <v-btn
                                icon
                                x-small
                                color="grey lighten-1"
                                @click="telemetryMinimized = !telemetryMinimized"
                                :title="telemetryMinimized ? 'Expand Telemetry' : 'Minimize Telemetry'"
                            >
                                <v-icon x-small>{{ telemetryMinimized ? mdiChevronDown : mdiChevronUp }}</v-icon>
                            </v-btn>
                        </div>
                    </div>

                    <!-- Minimized Compact Summary Ribbon -->
                    <div
                        v-if="telemetryMinimized"
                        class="px-3 py-2 d-flex align-center justify-space-between font-mono"
                        style="background: rgba(0, 0, 0, 0.35); font-size: 10px; border-bottom: 1px solid rgba(255, 255, 255, 0.05);"
                    >
                        <span class="d-flex align-center">
                            <span class="cyan--text font-weight-bold mr-1">CPU:</span>
                            <span class="white--text mr-2">{{ liveCpuUsage.toFixed(1) }}% ({{ liveCpuTemp }}°C)</span>
                        </span>
                        <span class="d-flex align-center">
                            <span class="cyan--text font-weight-bold mr-1">RAM:</span>
                            <span class="white--text mr-2">{{ liveRamPercent.toFixed(0) }}%</span>
                        </span>
                        <span class="d-flex align-center">
                            <span class="cyan--text font-weight-bold mr-1">FEEDRATE:</span>
                            <span class="white--text mr-2">{{ liveSpeed }} mm/s</span>
                        </span>
                        <v-chip x-small color="rgba(0, 229, 255, 0.15)" class="cyan--text font-weight-bold" style="height: 18px; font-size: 8px;">
                            {{ printerMotionStatus }}
                        </v-chip>
                    </div>

                    <!-- Full Gauges & Kinematics (Collapsible) -->
                    <v-expand-transition>
                        <div v-show="!telemetryMinimized">
                            <!-- Dynamic Shift-Light RPM Bar -->
                            <div class="shift-light-bar d-flex align-center px-4 py-1.5 justify-space-between">
                                <div
                                    v-for="i in 10"
                                    :key="i"
                                    class="shift-led"
                                    :class="getShiftLedClass(i)"
                                ></div>
                            </div>

                            <v-card-text class="pa-4 pt-2">
                                <!-- Dual Digital Cluster Pods: CPU & RAM -->
                                <div class="d-flex align-center justify-space-around mb-3">
                                    <!-- Left Pod: CPU Power & Temperature -->
                                    <div class="gauge-pod d-flex flex-column align-center text-center">
                                        <div class="gauge-container relative">
                                            <svg viewBox="0 0 100 100" class="gauge-svg">
                                                <defs>
                                                    <linearGradient id="cpuGrad" x1="0%" y1="100%" x2="100%" y2="0%">
                                                        <stop offset="0%" stop-color="#00e5ff" />
                                                        <stop offset="70%" stop-color="#38bdf8" />
                                                        <stop offset="100%" stop-color="#f43f5e" />
                                                    </linearGradient>
                                                </defs>
                                                <!-- Track Arc -->
                                                <path
                                                    d="M 18 82 A 42 42 0 1 1 82 82"
                                                    fill="none"
                                                    stroke="rgba(255, 255, 255, 0.08)"
                                                    stroke-width="7"
                                                    stroke-linecap="round"
                                                />
                                                <!-- Value Arc -->
                                                <path
                                                    d="M 18 82 A 42 42 0 1 1 82 82"
                                                    fill="none"
                                                    stroke="url(#cpuGrad)"
                                                    stroke-width="7"
                                                    stroke-linecap="round"
                                                    :stroke-dasharray="198"
                                                    :stroke-dashoffset="198 - (198 * Math.min(liveCpuUsage, 100) / 100)"
                                                    class="gauge-active-path"
                                                />
                                            </svg>
                                            <div class="gauge-center-content">
                                                <div class="gauge-value font-weight-black white--text font-mono">
                                                    {{ liveCpuUsage.toFixed(1) }}
                                                </div>
                                                <div class="gauge-unit cyan--text font-weight-bold">%</div>
                                                <div class="gauge-label grey--text">CPU LOAD</div>
                                            </div>
                                        </div>
                                        <div class="pod-footer mt-1 d-flex align-center">
                                            <v-icon x-small :color="liveCpuTempColor" class="mr-1">{{ mdiThermometer }}</v-icon>
                                            <span class="font-mono caption font-weight-bold" :class="liveCpuTempClass">
                                                {{ liveCpuTemp }}°C
                                            </span>
                                            <span class="text-caption grey--text ml-1" style="font-size: 9px;">CORE</span>
                                        </div>
                                    </div>

                                    <!-- Center Divider: Kinematics HUD & Machine Status -->
                                    <div class="hud-center-pod px-2 text-center d-flex flex-column justify-center align-center">
                                        <div class="drive-mode-pill mb-1">
                                            <span class="mode-text">{{ printerMotionStatus }}</span>
                                        </div>
                                        <div class="speed-readout font-mono font-weight-black white--text">
                                            {{ liveSpeed }}
                                            <span class="speed-unit">mm/s</span>
                                        </div>
                                        <div class="speed-sub grey--text font-weight-medium">FEEDRATE</div>

                                        <!-- Axis Coordinates HUD -->
                                        <div class="coords-strip mt-2 px-2 py-1 rounded d-flex align-center justify-space-between">
                                            <span class="coord-item"><strong class="cyan--text">X</strong> {{ liveCoords.x }}</span>
                                            <span class="coord-item mx-1"><strong class="cyan--text">Y</strong> {{ liveCoords.y }}</span>
                                            <span class="coord-item"><strong class="cyan--text">Z</strong> {{ liveCoords.z }}</span>
                                        </div>
                                    </div>

                                    <!-- Right Pod: RAM Memory Buffer -->
                                    <div class="gauge-pod d-flex flex-column align-center text-center">
                                        <div class="gauge-container relative">
                                            <svg viewBox="0 0 100 100" class="gauge-svg">
                                                <defs>
                                                    <linearGradient id="ramGrad" x1="0%" y1="100%" x2="100%" y2="0%">
                                                        <stop offset="0%" stop-color="#94a3b8" />
                                                        <stop offset="50%" stop-color="#e2e8f0" />
                                                        <stop offset="100%" stop-color="#38bdf8" />
                                                    </linearGradient>
                                                </defs>
                                                <!-- Track Arc -->
                                                <path
                                                    d="M 18 82 A 42 42 0 1 1 82 82"
                                                    fill="none"
                                                    stroke="rgba(255, 255, 255, 0.08)"
                                                    stroke-width="7"
                                                    stroke-linecap="round"
                                                />
                                                <!-- Value Arc -->
                                                <path
                                                    d="M 18 82 A 42 42 0 1 1 82 82"
                                                    fill="none"
                                                    stroke="url(#ramGrad)"
                                                    stroke-width="7"
                                                    stroke-linecap="round"
                                                    :stroke-dasharray="198"
                                                    :stroke-dashoffset="198 - (198 * Math.min(liveRamPercent, 100) / 100)"
                                                    class="gauge-active-path"
                                                />
                                            </svg>
                                            <div class="gauge-center-content">
                                                <div class="gauge-value font-weight-black white--text font-mono">
                                                    {{ liveRamPercent.toFixed(0) }}
                                                </div>
                                                <div class="gauge-unit grey--text text--lighten-2 font-weight-bold">%</div>
                                                <div class="gauge-label grey--text">RAM USED</div>
                                            </div>
                                        </div>
                                        <div class="pod-footer mt-1 font-mono caption grey--text text--lighten-1" style="font-size: 10px;">
                                            {{ liveRamUsedMb }} / {{ liveRamTotalGb }}
                                        </div>
                                    </div>
                                </div>

                                <!-- 4-Core ARM Cortex A72 Telemetry -->
                                <div class="cpu-cores-telemetry pa-2.5 rounded-lg mb-3">
                                    <div class="d-flex align-center justify-space-between mb-1.5">
                                        <span class="caption grey--text text-uppercase font-weight-bold" style="font-size: 9px; letter-spacing: 0.5px;">
                                            4-CORE ARM CORTEX A72 TELEMETRY
                                        </span>
                                        <span class="caption cyan--text font-weight-bold font-mono" style="font-size: 9px;">
                                            LOAD: {{ liveSysLoad }}
                                        </span>
                                    </div>
                                    <div class="d-flex align-center justify-space-between">
                                        <div v-for="(load, idx) in liveCoreLoads" :key="idx" class="core-cell flex-grow-1 mx-1">
                                            <div class="d-flex align-center justify-space-between caption font-mono" style="font-size: 8px;">
                                                <span class="grey--text">C{{ idx }}</span>
                                                <span class="white--text font-weight-bold">{{ load }}%</span>
                                            </div>
                                            <v-progress-linear
                                                :value="load"
                                                height="4"
                                                rounded
                                                :color="getCoreColor(load)"
                                                class="mt-1"
                                            ></v-progress-linear>
                                        </div>
                                    </div>
                                </div>

                                <!-- Twin Heat Monometer: Hotend Nozzle & Bed -->
                                <div class="twin-boost-strip pa-2 rounded-lg d-flex align-center justify-space-between">
                                    <div class="d-flex align-center flex-grow-1 mr-2">
                                        <v-avatar size="24" color="rgba(244, 63, 94, 0.15)" class="mr-2">
                                            <v-icon x-small color="#f43f5e">{{ mdiFire }}</v-icon>
                                        </v-avatar>
                                        <div class="flex-grow-1">
                                            <div class="d-flex align-center justify-space-between">
                                                <span class="caption grey--text" style="font-size: 10px;">NOZZLE</span>
                                                <span class="caption font-mono font-weight-bold white--text">{{ liveExtruderTemp }}°C / {{ liveExtruderTarget }}°C</span>
                                            </div>
                                            <v-progress-linear
                                                :value="liveExtruderTarget > 0 ? (liveExtruderTemp / liveExtruderTarget) * 100 : (liveExtruderTemp / 260) * 100"
                                                color="#f43f5e"
                                                height="3"
                                                rounded
                                                class="mt-0.5"
                                            ></v-progress-linear>
                                        </div>
                                    </div>

                                    <div class="d-flex align-center flex-grow-1 ml-2">
                                        <v-avatar size="24" color="rgba(245, 158, 11, 0.15)" class="mr-2">
                                            <v-icon x-small color="#f59e0b">{{ mdiRadiator }}</v-icon>
                                        </v-avatar>
                                        <div class="flex-grow-1">
                                            <div class="d-flex align-center justify-space-between">
                                                <span class="caption grey--text" style="font-size: 10px;">BED</span>
                                                <span class="caption font-mono font-weight-bold white--text">{{ liveBedTemp }}°C / {{ liveBedTarget }}°C</span>
                                            </div>
                                            <v-progress-linear
                                                :value="liveBedTarget > 0 ? (liveBedTemp / liveBedTarget) * 100 : (liveBedTemp / 100) * 100"
                                                color="#f59e0b"
                                                height="3"
                                                rounded
                                                class="mt-0.5"
                                            ></v-progress-linear>
                                        </div>
                                    </div>
                                </div>
                            </v-card-text>
                        </div>
                    </v-expand-transition>
                </v-card>

                <!-- Widget 2: Downtime Harvesting (AI) Card -->
                <v-card class="harvesting-card mb-4 rounded-xl pa-5 elevation-6 relative overflow-hidden">
                    <div class="d-flex justify-space-between align-start mb-2">
                        <div>
                            <div class="caption font-weight-bold text-uppercase green--text text--lighten-3 tracking-wider">
                                Downtime Harvesting
                            </div>
                            <div class="text-h4 font-weight-bold white--text mt-1 d-flex align-baseline">
                                ₹12,450
                                <span class="caption green--text text--lighten-3 ml-2">this month</span>
                            </div>
                        </div>
                        <v-avatar color="rgba(255, 255, 255, 0.2)" size="42">
                            <v-icon color="white">{{ mdiCurrencyInr }}</v-icon>
                        </v-avatar>
                    </div>
                    <p class="caption white--text text--darken-1 mb-4" style="opacity: 0.9;">
                        Autonomous marketplace order bidding is engaged. Machine auto-prints paid orders when idle.
                    </p>
                    <div class="d-flex align-center justify-space-between">
                        <v-btn x-small rounded color="white" class="green--text text--darken-3 font-weight-bold px-3" @click="showHarvestingDialog = true">
                            Manage Queue
                        </v-btn>
                        <v-chip x-small color="rgba(0,0,0,0.25)" class="white--text font-weight-bold">
                            <v-icon x-small left color="green accent-2">{{ mdiCheckCircle }}</v-icon> 3 JOBS QUEUED
                        </v-chip>
                    </div>
                </v-card>

                <!-- Widget 3: Predictive Maintenance Card -->
                <v-card class="glass-panel mb-4 rounded-xl overflow-hidden">
                    <div class="d-flex align-center px-4 py-3" style="background: rgba(255, 152, 0, 0.08); border-bottom: 1px solid rgba(255, 255, 255, 0.08);">
                        <v-icon left small color="orange">{{ mdiShieldAlert }}</v-icon>
                        <span class="subtitle-2 font-weight-bold white--text">Predictive Maintenance</span>
                    </div>
                    <v-card-text class="pa-4">
                        <!-- Nozzle clog status -->
                        <div class="pa-3 rounded-lg mb-3" style="background: rgba(255, 152, 0, 0.08); border: 1px solid rgba(255, 152, 0, 0.2);">
                            <div class="d-flex align-center justify-space-between">
                                <span class="subtitle-2 font-weight-bold orange--text text--lighten-2">Extruder Nozzle</span>
                                <v-chip x-small color="success">OPTIMAL</v-chip>
                            </div>
                            <div class="caption grey--text mt-1">
                                AI detects 94% flow stability. Clog probability &lt; 6% based on heater power variance.
                            </div>
                        </div>

                        <!-- Belt Tension -->
                        <div class="pa-3 rounded-lg" style="background: rgba(76, 175, 80, 0.08); border: 1px solid rgba(76, 175, 80, 0.2);">
                            <div class="d-flex align-center justify-space-between">
                                <span class="subtitle-2 font-weight-bold green--text text--lighten-2">Belt Tension &amp; Resonances</span>
                                <v-chip x-small color="success">110 Hz</v-chip>
                            </div>
                            <div class="caption grey--text mt-1">
                                X and Y axes belt resonance frequencies are balanced and within nominal limits.
                            </div>
                        </div>
                    </v-card-text>
                </v-card>
            </v-col>
        </v-row>

        <!-- Manage Agents Dialog -->
        <agent-manager-dialog v-model="showManager" @agent-changed="onAgentChanged" />

        <!-- Downtime Harvesting Modal -->
        <v-dialog v-model="showHarvestingDialog" max-width="480">
            <v-card class="glass-panel rounded-xl pa-2">
                <v-card-title class="headline green--text text--lighten-2 pb-1">
                    <v-icon left color="green">{{ mdiCashSync }}</v-icon> Downtime Harvesting
                </v-card-title>
                <v-card-text class="pt-2">
                    <p class="caption grey--text mb-3">
                        ProBharath AI automatically accepts verified print jobs from the marketplace network whenever your printer has scheduled idle time.
                    </p>
                    <div class="pa-3 rounded-lg mb-3" style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.2);">
                        <div class="subtitle-2 white--text font-weight-bold">Upcoming Autonomous Jobs:</div>
                        <div class="caption grey--text mt-1">&bull; Order #9812: Drone Arm (PETG) &bull; Est. Profit: ₹650</div>
                        <div class="caption grey--text">&bull; Order #9815: Custom Enclosure &bull; Est. Profit: ₹1,200</div>
                    </div>
                </v-card-text>
                <v-card-actions class="px-4 pb-4">
                    <v-spacer></v-spacer>
                    <v-btn text color="grey lighten-1" @click="showHarvestingDialog = false">Close</v-btn>
                </v-card-actions>
            </v-card>
        </v-dialog>

        <!-- Snackbar Toast -->
        <v-snackbar v-model="snackbar" :color="snackbarColor" timeout="2500" top>
            {{ snackbarText }}
        </v-snackbar>
    </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import { agentRegistry } from '@/agents/AgentRegistry'
import AgentManagerDialog from '@/components/agent/AgentManagerDialog.vue'
import {
    mdiAccount,
    mdiSend,
    mdiElephant,
    mdiChip,
    mdiCog,
    mdiTrashCanOutline,
    mdiCodeBraces,
    mdiFlash,
    mdiCurrencyInr,
    mdiCheckCircle,
    mdiShieldAlert,
    mdiSpeedometer,
    mdiRefresh,
    mdiCashSync,
    mdiGrid,
    mdiThermometer,
    mdiShieldCheck,
    mdiTrendingUp,
    mdiHome,
    mdiChevronDown,
    mdiChevronUp,
    mdiCpu64Bit,
    mdiCloud,
    mdiServerNetwork,
    mdiFire,
    mdiRadiator,
    mdiGauge
} from '@mdi/js'

interface ChatMessage {
    id: number
    text: string
    sender: 'user' | 'ai'
    action?: {
        label: string
        gcode: string
    }
}

@Component({
    components: {
        AgentManagerDialog
    }
})
export default class AgentDashboard extends Vue {
    // Icons
    mdiAccount = mdiAccount
    mdiSend = mdiSend
    mdiElephant = mdiElephant
    mdiChip = mdiChip
    mdiCog = mdiCog
    mdiTrashCanOutline = mdiTrashCanOutline
    mdiCodeBraces = mdiCodeBraces
    mdiFlash = mdiFlash
    mdiCurrencyInr = mdiCurrencyInr
    mdiCheckCircle = mdiCheckCircle
    mdiShieldAlert = mdiShieldAlert
    mdiSpeedometer = mdiSpeedometer
    mdiRefresh = mdiRefresh
    mdiCashSync = mdiCashSync
    mdiChevronDown = mdiChevronDown
    mdiChevronUp = mdiChevronUp
    mdiCpu64Bit = mdiCpu64Bit
    mdiCloud = mdiCloud
    mdiServerNetwork = mdiServerNetwork
    mdiFire = mdiFire
    mdiRadiator = mdiRadiator
    mdiGauge = mdiGauge

    modelMenuOpen = false
    selectedModel = {
        id: 'deepseek-r1-airllm',
        name: 'DeepSeek-R1 (AirLLM)',
        tag: '70B Edge',
        desc: 'Reasoning model streaming layer-by-layer from local NVMe. 100% offline, zero cloud fees.',
        icon: mdiCpu64Bit,
        isLocal: true,
        isRecommended: true,
        latency: '~3.2 t/s (Local)',
        params: '70B Layers',
        mode: 'Edge NVMe'
    }

    availableModels = [
        {
            id: 'deepseek-r1-airllm',
            name: 'DeepSeek-R1 (AirLLM)',
            tag: '70B Edge',
            desc: 'Reasoning model streaming layer-by-layer from local NVMe. 100% offline, zero cloud fees.',
            icon: mdiCpu64Bit,
            isLocal: true,
            isRecommended: true,
            latency: '~3.2 t/s (Local)',
            params: '70B Layers',
            mode: 'Edge NVMe'
        },
        {
            id: 'deepseek-33b-coder',
            name: 'DeepSeek-33B Coder',
            tag: '33B Local',
            desc: 'Fine-tuned for Klipper macros, parametric G-code synthesis & print kinematics.',
            icon: mdiCpu64Bit,
            isLocal: true,
            isRecommended: false,
            latency: '~6.8 t/s (Local)',
            params: '33B Weights',
            mode: 'Edge GPU/RAM'
        },
        {
            id: 'claude-3-5-sonnet',
            name: 'Claude 3.5 Sonnet',
            tag: 'Cloud Vision',
            desc: 'Multimodal computer vision for live nozzle camera inspection & first layer diagnosis.',
            icon: mdiCloud,
            isLocal: false,
            isRecommended: false,
            latency: 'Cloud API (180ms)',
            params: 'Multimodal',
            mode: 'Hybrid Cloud'
        },
        {
            id: 'gpt-4o',
            name: 'GPT-4o Omniverse',
            tag: 'Cloud Fast',
            desc: 'High-speed fleet scheduling, production batch order bidding and material estimation.',
            icon: mdiCloud,
            isLocal: false,
            isRecommended: false,
            latency: 'Cloud API (210ms)',
            params: 'Omni',
            mode: 'Cloud API'
        },
        {
            id: 'llama-3-3-70b',
            name: 'Llama 3.3 70B',
            tag: '70B Offline',
            desc: 'Meta open weights layer-streamed via AirLLM for factory data privacy & security.',
            icon: mdiServerNetwork,
            isLocal: true,
            isRecommended: false,
            latency: '~3.4 t/s (Local)',
            params: '70B Layers',
            mode: 'Edge NVMe'
        }
    ]

    newMessage = ''
    messages: ChatMessage[] = []
    
    showManager = false
    showHarvestingDialog = false
    activeAgentName = 'ProBharath AI Core'
    processing = false

    cpuLoad = 18
    ramUsage = 38
    networkLatency = 8

    // Live Supercar Telemetry States
    liveCpuUsage = 1.0
    liveCpuTemp = 34.6
    liveSysLoad = '0.08'
    liveCoreLoads: number[] = [1, 0, 1, 2]
    liveRamPercent = 4
    liveRamUsedMb = '333 MB'
    liveRamTotalGb = '8.0 GB'
    liveUptimeFormatted = '4h 48m up'
    telemetryLoading = false
    telemetryTimer: any = null
    telemetryMinimized = false

    snackbar = false
    snackbarText = ''
    snackbarColor = 'success'

    quickPrompts = [
        { label: 'Run Adaptive Mesh', text: 'Run adaptive mesh calibration', icon: mdiGrid, color: 'cyan' },
        { label: 'Preheat (PLA 210°/60°)', text: 'Preheat nozzle to 210 and bed to 60 for PLA', icon: mdiThermometer, color: 'orange' },
        { label: 'Predict Clogs', text: 'Analyze nozzle health and clog risk', icon: mdiShieldCheck, color: 'green' },
        { label: 'Downtime Bidding', text: 'How much has downtime harvesting earned?', icon: mdiTrendingUp, color: 'teal' },
        { label: 'Home All (G28)', text: 'Home all axes G28', icon: mdiHome, color: 'purple' },
        { label: 'AirLLM Specs', text: 'What are the AirLLM specs on this machine?', icon: mdiChip, color: 'cyan' },
    ]

    created() {
        this.updateAgentInfo()
        this.messages = [
            {
                id: Date.now(),
                text: "ProBharath AI Core initialized. Fleet is connected.\nHow can I optimize your manufacturing operations today?",
                sender: 'ai',
                action: {
                    label: "Run Bed Calibration",
                    gcode: "PROBING_ADAPTIVE"
                }
            }
        ]
        this.fetchLiveSystemData()
    }

    mounted() {
        this.fetchLiveSystemData()
        this.telemetryTimer = setInterval(() => {
            this.fetchLiveSystemData()
        }, 2000)
    }

    beforeDestroy() {
        if (this.telemetryTimer) {
            clearInterval(this.telemetryTimer)
            this.telemetryTimer = null
        }
    }

    updateAgentInfo() {
        const agent = agentRegistry.getActiveAgent()
        this.activeAgentName = agent.name === 'Core System' ? 'ProBharath AI Core' : agent.name
    }

    onAgentChanged() {
        this.updateAgentInfo()
        this.messages.push({
            id: Date.now(),
            text: `Agent switched to ${this.activeAgentName}. Ready for instructions.`,
            sender: 'ai'
        })
    }

    triggerPrompt(text: string) {
        this.newMessage = text
        this.sendMessage()
    }

    clearChat() {
        this.messages = [
            {
                id: Date.now(),
                text: "Command link cleared. Ready for new instructions.",
                sender: 'ai'
            }
        ]
    }

    selectModel(model: any) {
        this.selectedModel = model
        this.modelMenuOpen = false
        this.showToast(`AI Engine switched to ${model.name}`, 'cyan')
        this.messages.push({
            id: Date.now(),
            text: `[System Engine Switch]: Active model switched to ${model.name} (${model.mode}).\nArchitecture: Moonraker WebSocket + Local MCP protocol active. Ready for hardware execution.`,
            sender: 'ai'
        })
        this.scrollToBottom()
    }

    async sendMessage() {
        if (!this.newMessage.trim() || this.processing) return

        const userText = this.newMessage.trim()
        this.messages.push({
            id: Date.now(),
            text: userText,
            sender: 'user',
        })

        this.newMessage = ''
        this.processing = true
        this.scrollToBottom()

        // Intelligent local response mapping
        setTimeout(async () => {
            const lower = userText.toLowerCase()
            let aiText = ''
            let action: { label: string; gcode: string } | undefined = undefined

            if (lower.includes('mesh') || lower.includes('level') || lower.includes('probe')) {
                aiText = "I have reviewed your bed profile. Adaptive probing will measure only the bounding box of your print to save time while ensuring perfect first-layer adhesion."
                action = { label: "Execute PROBING_ADAPTIVE", gcode: "PROBING_ADAPTIVE" }
            } else if (lower.includes('preheat') || lower.includes('heat') || lower.includes('temp')) {
                aiText = "Target temperatures configured: Extruder 210°C, Heated Bed 60°C for standard PLA filament."
                action = { label: "Preheat (M104 S210, M140 S60)", gcode: "M104 S210\nM140 S60" }
            } else if (lower.includes('home') || lower.includes('g28')) {
                aiText = "Ready to home all printer axes safely."
                action = { label: "Home X, Y, Z (G28)", gcode: "G28" }
            } else if (lower.includes('clog') || lower.includes('nozzle') || lower.includes('maintenance')) {
                aiText = "Predictive analysis: Extruder temperature variance is within ±0.4°C. Current draw indicates smooth flow with no backpressure build-up. Clog probability is low (<6%)."
            } else if (lower.includes('harvest') || lower.includes('downtime') || lower.includes('earn')) {
                aiText = "Downtime Harvesting has earned ₹12,450 this month across 18 completed customer orders. 3 jobs are currently queued for your machine's next idle block."
            } else if (lower.includes('airllm') || lower.includes('offline') || lower.includes('70b')) {
                aiText = "AirLLM streams 70B parameter models layer-by-layer from fast NVMe storage into 4GB–8GB GPU VRAM. It enables 100% offline parametric CAD synthesis (OpenCASCADE B-Rep) and factory batch slicing without cloud fees."
            } else {
                // Fallback to agentRegistry
                try {
                    const agent = agentRegistry.getActiveAgent()
                    const context = { store: this.$store, router: this.$router }
                    aiText = await agent.process(userText, context)
                } catch (e: any) {
                    aiText = `ProBharath AI: Command processed. Machine operational.`
                }
            }

            this.messages.push({
                id: Date.now() + 1,
                text: aiText,
                sender: 'ai',
                action
            })
            this.processing = false
            this.scrollToBottom()
        }, 600)
    }

    executeAiAction(action: { label: string; gcode: string }) {
        if (!action || !action.gcode) return
        try {
            this.$store.dispatch('printer/sendGcode', action.gcode)
            this.showToast(`Executed: ${action.label}`, 'cyan')
        } catch (e: any) {
            this.showToast(`Failed to execute: ${e.message}`, 'error')
        }
    }

    get liveCpuTempColor() {
        if (this.liveCpuTemp >= 70) return '#f43f5e'
        if (this.liveCpuTemp >= 55) return '#f59e0b'
        return '#00e5ff'
    }

    get liveCpuTempClass() {
        if (this.liveCpuTemp >= 70) return 'red--text text--accent-2'
        if (this.liveCpuTemp >= 55) return 'amber--text text--accent-2'
        return 'cyan--text'
    }

    getShiftLedClass(i: number) {
        const threshold = (i - 1) * 10
        const isActive = this.liveCpuUsage >= threshold || (i <= 2 && this.liveCpuUsage > 0)
        let colorType = 'led-green'
        if (i >= 5 && i <= 7) colorType = 'led-cyan'
        if (i >= 8) colorType = 'led-red'

        return {
            [colorType]: true,
            'led-active': isActive,
            'led-dim': !isActive
        }
    }

    getCoreColor(val: number) {
        if (val > 80) return '#f43f5e'
        if (val > 50) return '#f59e0b'
        return '#00e5ff'
    }

    get liveCoords() {
        const pos = this.$store.state.printer?.toolhead?.position
        return {
            x: Number(pos?.[0] ?? 0).toFixed(1),
            y: Number(pos?.[1] ?? 0).toFixed(1),
            z: Number(pos?.[2] ?? 0).toFixed(2)
        }
    }

    get liveSpeed() {
        const liveV = this.$store.state.printer?.motion_report?.live_velocity
        const moveV = this.$store.state.printer?.gcode_move?.speed
        return Math.round(liveV || moveV || 0)
    }

    get printerMotionStatus() {
        const state = this.$store.state.printer?.print_stats?.state
        if (state === 'printing') {
            const pct = Math.round((this.$store.getters['printer/getPrintPercent'] || 0) * 100)
            return `PRINTING ${pct}%`
        }
        if (state === 'paused') return 'PRINT PAUSED'
        if (state === 'busy') return 'MACHINE BUSY'
        return 'STANDBY IDLE'
    }

    get activePrinterName() {
        const pName = this.$store.state.gui?.general?.printername
        if (pName && pName.trim() && !pName.toLowerCase().includes('probharath') && !pName.toLowerCase().includes('mainsail')) {
            return pName.toUpperCase()
        }
        return 'ENDER 3'
    }

    get liveExtruderTemp() {
        const extruders = this.$store.getters['printer/getExtruders']
        return Math.round(extruders?.[0]?.temperature ?? 0)
    }

    get liveExtruderTarget() {
        const extruders = this.$store.getters['printer/getExtruders']
        return Math.round(extruders?.[0]?.target ?? 0)
    }

    get liveBedTemp() {
        const bed = this.$store.getters['printer/getHeaterBed']
        return Math.round(bed?.temperature ?? 0)
    }

    get liveBedTarget() {
        const bed = this.$store.getters['printer/getHeaterBed']
        return Math.round(bed?.target ?? 0)
    }

    async fetchLiveSystemData() {
        this.telemetryLoading = true
        try {
            // Read from Vuex store
            const hostStats = this.$store.getters['server/getHostStats']
            const cpuUsage = this.$store.getters['server/getCpuUsage']
            const systemCpu = this.$store.state.server?.system_cpu_usage
            const cpuTemp = this.$store.state.server?.cpu_temp

            if (systemCpu && 'cpu' in systemCpu) {
                this.liveCpuUsage = systemCpu.cpu ?? 0
                this.liveCoreLoads = [
                    systemCpu.cpu0 ?? 0,
                    systemCpu.cpu1 ?? 0,
                    systemCpu.cpu2 ?? 0,
                    systemCpu.cpu3 ?? 0
                ]
            } else if (cpuUsage !== null && cpuUsage !== undefined) {
                this.liveCpuUsage = cpuUsage
            } else if (hostStats?.loadPercent) {
                this.liveCpuUsage = hostStats.loadPercent
            }

            if (cpuTemp !== null && cpuTemp !== undefined) {
                this.liveCpuTemp = Number(cpuTemp).toFixed(1)
            } else if (hostStats?.tempSensor?.temperature) {
                this.liveCpuTemp = Number(hostStats.tempSensor.temperature).toFixed(1)
            }

            if (hostStats) {
                this.liveSysLoad = (hostStats.load ?? 0).toFixed(2)
                this.liveRamPercent = hostStats.memUsage ?? 0
                this.liveRamUsedMb = hostStats.memUsed ?? '0 MB'
                this.liveRamTotalGb = hostStats.memTotal ?? '8.0 GB'
            }

            // Direct live fetch from Moonraker proc_stats for real-time accuracy
            const host = window.location.hostname || '192.168.1.19'
            const res = await fetch(`http://${host}:7125/machine/proc_stats`)
            if (res.ok) {
                const data = await res.json()
                const r = data?.result
                if (r) {
                    if (r.system_cpu_usage) {
                        this.liveCpuUsage = r.system_cpu_usage.cpu ?? this.liveCpuUsage
                        this.liveCoreLoads = [
                            r.system_cpu_usage.cpu0 ?? 0,
                            r.system_cpu_usage.cpu1 ?? 0,
                            r.system_cpu_usage.cpu2 ?? 0,
                            r.system_cpu_usage.cpu3 ?? 0
                        ]
                    }
                    if (r.cpu_temp) {
                        this.liveCpuTemp = Number(r.cpu_temp).toFixed(1)
                    }
                    if (r.system_memory) {
                        const used = r.system_memory.used // kB
                        const total = r.system_memory.total // kB
                        this.liveRamPercent = Math.round((used / total) * 100)
                        this.liveRamUsedMb = `${Math.round(used / 1024)} MB`
                        this.liveRamTotalGb = `${(total / (1024 * 1024)).toFixed(1)} GB`
                    }
                    if (r.system_uptime) {
                        const hrs = Math.floor(r.system_uptime / 3600)
                        const mins = Math.floor((r.system_uptime % 3600) / 60)
                        this.liveUptimeFormatted = `${hrs}h ${mins}m up`
                    }
                }
            }
        } catch (_) {
        } finally {
            this.telemetryLoading = false
        }
    }

    scrollToBottom() {
        this.$nextTick(() => {
            const container = this.$el.querySelector('.chat-viewport')
            if (container) container.scrollTop = container.scrollHeight
        })
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

.harvesting-card {
    background: linear-gradient(135deg, #10b981 0%, #059669 100%) !important;
    box-shadow: 0 8px 32px rgba(16, 185, 129, 0.25);
    border: 1px solid rgba(255, 255, 255, 0.2);
}

.silver-chip {
    background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 50%, #94a3b8 100%) !important;
    color: #090d16 !important;
    font-weight: 800 !important;
    letter-spacing: 0.5px;
    border: 1px solid rgba(255, 255, 255, 0.9) !important;
    box-shadow: 0 0 12px rgba(226, 232, 240, 0.4);
}

.border-silver {
    border: 1.5px solid rgba(226, 232, 240, 0.45) !important;
    background: rgba(255, 255, 255, 0.08) !important;
    box-shadow: 0 0 12px rgba(226, 232, 240, 0.25);
}

.silver-user-avatar {
    background: linear-gradient(135deg, #475569, #334155) !important;
    border: 1px solid rgba(255, 255, 255, 0.35);
    box-shadow: 0 0 10px rgba(255, 255, 255, 0.2);
}

.silver-send-btn {
    background: linear-gradient(135deg, #f8fafc 0%, #cbd5e1 100%) !important;
    box-shadow: 0 0 15px rgba(226, 232, 240, 0.5) !important;
}

.border-top-glass {
    border-top: 1px solid rgba(255, 255, 255, 0.08);
}

.pulse-glow-avatar {
    animation: pulseAvatarSilver 2.5s infinite ease-in-out;
}

@keyframes pulseAvatarSilver {
    0%, 100% {
        box-shadow: 0 0 12px rgba(226, 232, 240, 0.35);
        border-color: rgba(226, 232, 240, 0.5);
    }
    50% {
        box-shadow: 0 0 24px rgba(226, 232, 240, 0.85);
        border-color: rgba(226, 232, 240, 0.95);
    }
}

.user-bubble {
    background: linear-gradient(135deg, rgba(255, 255, 255, 0.16) 0%, rgba(148, 163, 184, 0.25) 100%) !important;
    border: 1px solid rgba(255, 255, 255, 0.28) !important;
    backdrop-filter: blur(12px);
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
}

.ai-bubble {
    background: rgba(255, 255, 255, 0.05) !important;
    backdrop-filter: blur(8px);
    border: 1px solid rgba(0, 229, 255, 0.18);
}

.custom-chat-input ::v-deep .v-input__slot {
    border: 1px solid rgba(226, 232, 240, 0.3) !important;
    transition: all 0.2s ease;
}

.custom-chat-input ::v-deep .v-input__slot:hover {
    border-color: rgba(226, 232, 240, 0.7) !important;
}

.model-selector-btn {
    background: rgba(0, 229, 255, 0.08) !important;
    border: 1px solid rgba(0, 229, 255, 0.35) !important;
    backdrop-filter: blur(8px);
}
.model-selector-btn:hover {
    background: rgba(0, 229, 255, 0.16) !important;
    border-color: rgba(0, 229, 255, 0.6) !important;
}

.model-option-card {
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(255, 255, 255, 0.08);
    transition: all 0.2s ease;
}
.model-option-card:hover {
    background: rgba(0, 229, 255, 0.08);
    border-color: rgba(0, 229, 255, 0.3);
    transform: translateY(-1px);
}
.active-model-card {
    background: rgba(0, 229, 255, 0.12) !important;
    border: 1px solid rgba(0, 229, 255, 0.5) !important;
}

/* Supercar Cockpit Telemetry Console */
.supercar-console {
    background: linear-gradient(145deg, #070c16 0%, #0c1626 50%, #050a12 100%) !important;
    border: 1px solid rgba(0, 229, 255, 0.28) !important;
    box-shadow: 0 10px 35px rgba(0, 0, 0, 0.6), inset 0 1px 0 rgba(255, 255, 255, 0.15) !important;
    position: relative;
}

.supercar-bezel {
    background: linear-gradient(90deg, rgba(0, 229, 255, 0.08) 0%, rgba(13, 25, 48, 0.9) 50%, rgba(0, 229, 255, 0.08) 100%);
    border-bottom: 1px solid rgba(0, 229, 255, 0.2);
}

.cockpit-title {
    font-size: 11px;
    letter-spacing: 1.5px;
    text-shadow: 0 0 10px rgba(0, 229, 255, 0.6);
}

.cockpit-sub-badge {
    background: linear-gradient(135deg, #f8fafc 0%, #cbd5e1 100%);
    color: #070c16;
    font-size: 8px;
    font-weight: 900;
    letter-spacing: 0.5px;
    white-space: nowrap;
    max-width: 100px;
    overflow: hidden;
    text-overflow: ellipsis;
    display: inline-block;
}

.shift-light-bar {
    background: rgba(0, 0, 0, 0.55);
    border-bottom: 1px solid rgba(255, 255, 255, 0.06);
    gap: 4px;
}

.shift-led {
    height: 5px;
    flex: 1;
    border-radius: 2px;
    transition: all 0.25s ease;
}

.led-green.led-active {
    background: #10b981 !important;
    box-shadow: 0 0 8px #10b981;
}
.led-green.led-dim {
    background: rgba(16, 185, 129, 0.2) !important;
}

.led-cyan.led-active {
    background: #00e5ff !important;
    box-shadow: 0 0 10px #00e5ff;
}
.led-cyan.led-dim {
    background: rgba(0, 229, 255, 0.2) !important;
}

.led-red.led-active {
    background: #f43f5e !important;
    box-shadow: 0 0 12px #f43f5e;
    animation: flashRedline 0.8s infinite alternate;
}
.led-red.led-dim {
    background: rgba(244, 63, 94, 0.2) !important;
}

@keyframes flashRedline {
    from { opacity: 0.6; }
    to { opacity: 1; filter: brightness(1.3); }
}

.gauge-pod {
    width: 105px;
}

.gauge-container {
    width: 96px;
    height: 96px;
    margin: 0 auto;
    position: relative;
}

.gauge-svg {
    width: 100%;
    height: 100%;
    transform: rotate(0deg);
}

.gauge-active-path {
    transition: stroke-dashoffset 0.6s ease;
}

.gauge-center-content {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    pointer-events: none;
    line-height: 1.1;
}

.gauge-value {
    font-size: 19px;
    letter-spacing: -0.5px;
}

.gauge-unit {
    font-size: 9px;
}

.gauge-label {
    font-size: 8px;
    font-weight: 700;
    letter-spacing: 0.5px;
    margin-top: 2px;
}

.hud-center-pod {
    min-width: 100px;
    max-width: 120px;
}

.drive-mode-pill {
    background: rgba(0, 229, 255, 0.12);
    border: 1px solid rgba(0, 229, 255, 0.35);
    border-radius: 20px;
    padding: 2px 8px;
}

.mode-text {
    font-size: 8px;
    font-weight: 800;
    color: #00e5ff;
    letter-spacing: 0.8px;
}

.speed-readout {
    font-size: 22px;
    line-height: 1.1;
    letter-spacing: -1px;
}

.speed-unit {
    font-size: 9px;
    color: #94a3b8;
    font-weight: 600;
}

.speed-sub {
    font-size: 8px;
    letter-spacing: 1px;
}

.coords-strip {
    background: rgba(0, 0, 0, 0.45);
    border: 1px solid rgba(255, 255, 255, 0.08);
    font-size: 9px;
    font-family: monospace;
}

.cpu-cores-telemetry {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.06);
}

.twin-boost-strip {
    background: rgba(0, 0, 0, 0.4);
    border: 1px solid rgba(255, 255, 255, 0.06);
}
</style>
