<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
<template>
    <div class="custom-mesh-map">
        <div class="presets-container px-2 pt-2">
            <v-row align="center">
                <v-col cols="12" sm="5">
                    <v-select
                        v-model="selectedPreset"
                        :items="presetItems"
                        label="Saved Profiles"
                        hide-details
                        dense
                        outlined
                        @change="loadPreset"
                    ></v-select>
                </v-col>
                <v-col cols="8" sm="4">
                    <v-text-field
                        v-model="newPresetName"
                        label="New Profile Name"
                        hide-details
                        dense
                        outlined
                    ></v-text-field>
                </v-col>
                <v-col cols="4" sm="3">
                    <v-btn color="primary" small @click="savePreset" :disabled="!newPresetName">
                        <v-icon left>mdi-content-save</v-icon> Save
                    </v-btn>
                </v-col>
            </v-row>
        </div>

        <div class="sliders-container">
            <v-range-slider
                v-model="xRange"
                :max="bedMax[0]"
                :min="bedMin[0]"
                label="X-Axis Range"
                class="mt-6"
                @change="updateBounds"
            >
                <template v-slot:prepend>
                    <v-text-field
                        v-model.number="xRange[0]"
                        class="mt-0 pt-0"
                        hide-details
                        single-line
                        type="number"
                        style="width: 60px"
                        @change="updateBounds"
                    ></v-text-field>
                </template>
                <template v-slot:append>
                    <v-text-field
                        v-model.number="xRange[1]"
                        class="mt-0 pt-0"
                        hide-details
                        single-line
                        type="number"
                        style="width: 60px"
                        @change="updateBounds"
                    ></v-text-field>
                </template>
            </v-range-slider>
            
            <v-range-slider
                v-model="yRange"
                :max="bedMax[1]"
                :min="bedMin[1]"
                label="Y-Axis Range"
                class="mt-2"
                @change="updateBounds"
            >
                <template v-slot:prepend>
                    <v-text-field
                        v-model.number="yRange[0]"
                        class="mt-0 pt-0"
                        hide-details
                        single-line
                        type="number"
                        style="width: 60px"
                        @change="updateBounds"
                    ></v-text-field>
                </template>
                <template v-slot:append>
                    <v-text-field
                        v-model.number="yRange[1]"
                        class="mt-0 pt-0"
                        hide-details
                        single-line
                        type="number"
                        style="width: 60px"
                        @change="updateBounds"
                    ></v-text-field>
                </template>
            </v-range-slider>
            
            <v-row>
                <v-col>
                    <v-text-field
                        v-model.number="probeCount.x"
                        label="X Probe Count"
                        type="number"
                        @change="onProbesChanged"
                    ></v-text-field>
                </v-col>
                <v-col>
                    <v-text-field
                        v-model.number="probeCount.y"
                        label="Y Probe Count"
                        type="number"
                        @change="onProbesChanged"
                    ></v-text-field>
                </v-col>
            </v-row>
            
            <v-row class="mb-2">
                <v-col class="text-center">
                    <v-btn color="secondary" outlined small @click="calibrateProbeZOffset">
                        <v-icon left>mdi-arrow-up-down</v-icon>
                        Calibrate Probe Z-Offset
                    </v-btn>
                </v-col>
            </v-row>
        </div>

        <svg
            version="1.1"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            :viewBox="viewBox"
            xml:space="preserve"
            class="map-svg"
            ref="svgMap"
            @mousedown="onMouseDown($event, 'new')"
            @mousemove="onMouseMove"
            @mouseup="onMouseUp"
            @mouseleave="onMouseUp"
            style="cursor: crosshair"
            draggable="false"
        >
            <g>
                <line
                    v-for="x in xStripes"
                    :key="'xLines' + x"
                    :x1="x"
                    :x2="x"
                    :y1="convertY(absoluteBedMin[1])"
                    :y2="convertY(absoluteBedMax[1])"
                    :stroke="coordinationCrossColor"
                    :stroke-opacity="0.25"
                    stroke-width="1" />
                <line
                    v-for="y in yStripes"
                    :key="'yLines' + y"
                    :x1="absoluteBedMin[0]"
                    :x2="absoluteBedMax[0]"
                    :y1="convertY(y)"
                    :y2="convertY(y)"
                    :stroke="coordinationCrossColor"
                    :stroke-opacity="0.25"
                    stroke-width="1" />
            </g>

            <!-- Draw the selected area -->
            <rect
                :x="xRange[0]"
                :y="convertY(yRange[1])"
                :width="Math.abs(xRange[1] - xRange[0])"
                :height="Math.abs(yRange[1] - yRange[0])"
                :fill="primaryColor"
                fill-opacity="0.3"
                stroke-width="2"
                :stroke="primaryColor"
                @mousedown.stop="onMouseDown($event, 'box')"
                style="cursor: move"
            />
            
            <!-- Resize Handles -->
            <!-- NW -->
            <rect :x="xRange[0] - 3" :y="convertY(yRange[1]) - 3" width="6" height="6" fill="#fff" :stroke="primaryColor" stroke-width="1.5" style="cursor: nwse-resize" @mousedown.stop="onMouseDown($event, 'nw')" />
            <!-- NE -->
            <rect :x="xRange[1] - 3" :y="convertY(yRange[1]) - 3" width="6" height="6" fill="#fff" :stroke="primaryColor" stroke-width="1.5" style="cursor: nesw-resize" @mousedown.stop="onMouseDown($event, 'ne')" />
            <!-- SW -->
            <rect :x="xRange[0] - 3" :y="convertY(yRange[0]) - 3" width="6" height="6" fill="#fff" :stroke="primaryColor" stroke-width="1.5" style="cursor: nesw-resize" @mousedown.stop="onMouseDown($event, 'sw')" />
            <!-- SE -->
            <rect :x="xRange[1] - 3" :y="convertY(yRange[0]) - 3" width="6" height="6" fill="#fff" :stroke="primaryColor" stroke-width="1.5" style="cursor: nwse-resize" @mousedown.stop="onMouseDown($event, 'se')" />
            
            <!-- Draw the probe points -->
            <circle
                v-for="(pt, idx) in probePoints"
                :key="'pt' + idx"
                :cx="pt.x"
                :cy="convertY(pt.y)"
                r="2"
                fill="#fff"
                :stroke="primaryColor"
                stroke-width="1"
            />
        </svg>
    </div>
</template>

<script lang="ts">
import Component from 'vue-class-component'
import { Mixins, Watch } from 'vue-property-decorator'
import BaseMixin from '@/components/mixins/base'
import { defaultPrimaryColor } from '@/store/variables'

@Component
export default class HeightmapCustomMeshMap extends Mixins(BaseMixin) {
    private coordinationCrossColor = '#888'
    private stripesOffset = 50

    xRange: number[] = [0, 200]
    yRange: number[] = [0, 200]
    
    probeCount = {
        x: 5,
        y: 5
    }
    
    dragMode = 'none'
    dragStartCoords = { x: 0, y: 0 }
    dragStartRange = { x: [0, 0], y: [0, 0] }
    
    selectedPreset = 'Default'
    newPresetName = ''

    mounted() {
        this.loadPreset() // Will load 'Default' limits
    }

    get toolhead() {
        return this.$store.state.printer.toolhead ?? {}
    }
    
    get probeConfig() {
        return this.$store.state.printer.configfile?.settings?.probe || 
               this.$store.state.printer.configfile?.settings?.bltouch || {}
    }

    get xOffset() {
        return this.probeConfig.x_offset ?? 0
    }

    get yOffset() {
        return this.probeConfig.y_offset ?? 0
    }

    get bedMin() {
        const min = this.toolhead.axis_minimum ?? [0, 0]
        return [
            Math.max(min[0], min[0] + this.xOffset),
            Math.max(min[1], min[1] + this.yOffset)
        ]
    }

    get bedMax() {
        const max = this.toolhead.axis_maximum ?? [200, 200]
        return [
            Math.min(max[0], max[0] + this.xOffset),
            Math.min(max[1], max[1] + this.yOffset)
        ]
    }
    
    get absoluteBedMin() {
        return this.toolhead.axis_minimum ?? [0, 0]
    }
    
    get absoluteBedMax() {
        return this.toolhead.axis_maximum ?? [200, 200]
    }

    get absoluteX() {
        return Math.abs(this.absoluteBedMin[0]) + Math.abs(this.absoluteBedMax[0])
    }

    get absoluteY() {
        return Math.abs(this.absoluteBedMin[1]) + Math.abs(this.absoluteBedMax[1])
    }

    get viewBox() {
        return (
            this.absoluteBedMin[0] +
            ' ' +
            this.convertY(this.absoluteBedMax[1]) +
            ' ' +
            this.absoluteX +
            ' ' +
            this.absoluteY
        )
    }

    get xStripes() {
        const output = []
        const minXstripe = Math.floor(this.absoluteBedMin[0] / this.stripesOffset) * this.stripesOffset
        const maxXstripe = Math.floor(this.absoluteBedMax[0] / this.stripesOffset) * this.stripesOffset

        for (let i = minXstripe; i <= maxXstripe; i = i + this.stripesOffset) {
            output.push(i)
        }
        return output
    }

    get yStripes() {
        const output = []
        const minYstripe = Math.floor(this.absoluteBedMin[1] / this.stripesOffset) * this.stripesOffset
        const maxYstripe = Math.floor(this.absoluteBedMax[1] / this.stripesOffset) * this.stripesOffset

        for (let i = minYstripe; i <= maxYstripe; i = i + this.stripesOffset) {
            output.push(i)
        }
        return output
    }

    get primaryColor() {
        return this.$store.state.gui.theme?.primary ?? defaultPrimaryColor
    }
    
    get customPresets() {
        return this.$store.state.gui.view?.heightmap?.customPresets || {}
    }

    get presetItems() {
        return ['Default', ...Object.keys(this.customPresets)]
    }
    
    get probePoints() {
        const points = []
        const pX = Math.max(2, this.probeCount.x)
        const pY = Math.max(2, this.probeCount.y)
        
        const xStep = (this.xRange[1] - this.xRange[0]) / (pX - 1)
        const yStep = (this.yRange[1] - this.yRange[0]) / (pY - 1)
        
        for (let i = 0; i < pX; i++) {
            const x = this.xRange[0] + (i * xStep)
            for (let j = 0; j < pY; j++) {
                const y = this.yRange[0] + (j * yStep)
                points.push({ x, y })
            }
        }
        return points
    }

    convertY(y: number) {
        return y * -1
    }

    updateBounds() {
        this.$emit('update:bounds', {
            xMin: this.xRange[0],
            xMax: this.xRange[1],
            yMin: this.yRange[0],
            yMax: this.yRange[1]
        })
    }
    
    @Watch('probeCount', { deep: true })
    onProbesChanged() {
        this.$emit('update:probes', this.probeCount)
    }
    
    getMouseCoords(evt: MouseEvent) {
        const svg = this.$refs.svgMap as SVGSVGElement
        const pt = svg.createSVGPoint()
        pt.x = evt.clientX
        pt.y = evt.clientY
        const loc = pt.matrixTransform(svg.getScreenCTM()?.inverse())
        return { x: loc.x, y: this.convertY(loc.y) }
    }
    
    onMouseDown(evt: MouseEvent, mode: string) {
        this.dragMode = mode
        const loc = this.getMouseCoords(evt)
        this.dragStartCoords = { x: loc.x, y: loc.y }
        this.dragStartRange = { x: [...this.xRange], y: [...this.yRange] }
        
        if (mode === 'new') {
            this.xRange = [Math.round(loc.x), Math.round(loc.x)]
            this.yRange = [Math.round(loc.y), Math.round(loc.y)]
        }
        this.updateBounds()
    }

    onMouseMove(evt: MouseEvent) {
        if (this.dragMode === 'none') return
        const loc = this.getMouseCoords(evt)
        
        if (this.dragMode === 'new') {
            const xMin = Math.max(this.bedMin[0], Math.min(this.dragStartCoords.x, loc.x))
            const xMax = Math.min(this.bedMax[0], Math.max(this.dragStartCoords.x, loc.x))
            const yMin = Math.max(this.bedMin[1], Math.min(this.dragStartCoords.y, loc.y))
            const yMax = Math.min(this.bedMax[1], Math.max(this.dragStartCoords.y, loc.y))
            this.xRange = [Math.round(xMin), Math.round(xMax)]
            this.yRange = [Math.round(yMin), Math.round(yMax)]
        } 
        else if (this.dragMode === 'box') {
            const dx = Math.round(loc.x - this.dragStartCoords.x)
            const dy = Math.round(loc.y - this.dragStartCoords.y)
            const w = this.dragStartRange.x[1] - this.dragStartRange.x[0]
            const h = this.dragStartRange.y[1] - this.dragStartRange.y[0]
            
            let newXMin = this.dragStartRange.x[0] + dx
            let newXMax = this.dragStartRange.x[1] + dx
            if (newXMin < this.bedMin[0]) { newXMin = this.bedMin[0]; newXMax = newXMin + w; }
            if (newXMax > this.bedMax[0]) { newXMax = this.bedMax[0]; newXMin = newXMax - w; }
            
            let newYMin = this.dragStartRange.y[0] + dy
            let newYMax = this.dragStartRange.y[1] + dy
            if (newYMin < this.bedMin[1]) { newYMin = this.bedMin[1]; newYMax = newYMin + h; }
            if (newYMax > this.bedMax[1]) { newYMax = this.bedMax[1]; newYMin = newYMax - h; }
            
            this.xRange = [newXMin, newXMax]
            this.yRange = [newYMin, newYMax]
        }
        else {
            let newX0 = this.dragStartRange.x[0]
            let newX1 = this.dragStartRange.x[1]
            let newY0 = this.dragStartRange.y[0]
            let newY1 = this.dragStartRange.y[1]

            if (this.dragMode.includes('w')) {
                newX0 = Math.max(this.bedMin[0], Math.min(newX1 - 1, loc.x))
            }
            if (this.dragMode.includes('e')) {
                newX1 = Math.min(this.bedMax[0], Math.max(newX0 + 1, loc.x))
            }
            if (this.dragMode.includes('s')) {
                newY0 = Math.max(this.bedMin[1], Math.min(newY1 - 1, loc.y))
            }
            if (this.dragMode.includes('n')) {
                newY1 = Math.min(this.bedMax[1], Math.max(newY0 + 1, loc.y))
            }
            this.xRange = [Math.round(newX0), Math.round(newX1)]
            this.yRange = [Math.round(newY0), Math.round(newY1)]
        }
        this.updateBounds()
    }

    onMouseUp() {
        if (this.dragMode !== 'none') {
            this.dragMode = 'none'
            this.updateBounds()
        }
    }
    
    savePreset() {
        if (!this.newPresetName) return
        const presets = { ...this.customPresets }
        presets[this.newPresetName] = {
            xRange: this.xRange,
            yRange: this.yRange,
            probeCount: this.probeCount
        }
        this.$store.dispatch('gui/saveSetting', { name: 'view.heightmap.customPresets', value: presets })
        this.selectedPreset = this.newPresetName
        this.newPresetName = ''
    }

    loadPreset() {
        if (this.selectedPreset === 'Default') {
            const defaultMesh = this.$store.state.printer.configfile?.settings?.bed_mesh || {}
            const defaultMin = defaultMesh.mesh_min || this.bedMin
            const defaultMax = defaultMesh.mesh_max || this.bedMax
            this.xRange = [
                Math.max(this.bedMin[0], defaultMin[0]),
                Math.min(this.bedMax[0], defaultMax[0])
            ]
            this.yRange = [
                Math.max(this.bedMin[1], defaultMin[1]),
                Math.min(this.bedMax[1], defaultMax[1])
            ]
            const defaultCount = defaultMesh.probe_count || [5, 5]
            this.probeCount = {
                x: defaultCount[0],
                y: defaultCount.length > 1 ? defaultCount[1] : defaultCount[0]
            }
        } else {
            const preset = this.customPresets[this.selectedPreset]
            if (preset) {
                this.xRange = [...preset.xRange]
                this.yRange = [...preset.yRange]
                this.probeCount = { ...preset.probeCount }
            }
        }
        this.updateBounds()
        this.onProbesChanged()
    }
    
    calibrateProbeZOffset() {
        const x_max = this.$store.state.printer.configfile.settings.stepper_x.position_max || 200
        const y_max = this.$store.state.printer.configfile.settings.stepper_y.position_max || 200
        const center_x = x_max / 2
        const center_y = y_max / 2

        let script = ''
        if (this.$store.state.printer.toolhead?.homed_axes !== 'xyz') {
            script += 'G28\n'
        }
        script += `G0 X${center_x} Y${center_y} Z10 F3000\nPROBE_CALIBRATE`

        this.$store.dispatch('server/addEvent', { message: script, type: 'command' })
        this.$socket.emit('printer.gcode.script', { script })
        this.$emit('close')
    }
}
</script>

<style scoped>
.custom-mesh-map {
    width: 100%;
}
.map-svg {
    border: 2px solid #888;
    width: 100%;
    margin-top: 10px;
    background-color: rgba(0, 0, 0, 0.1);
}
.sliders-container {
    padding: 0 10px;
}
.presets-container {
    background-color: rgba(0, 0, 0, 0.05);
    border-radius: 4px;
}
</style>
