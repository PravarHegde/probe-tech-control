<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
<template>
    <v-dialog v-model="showDialog" persistent :max-width="400" @keydown.esc="closeDialog">
        <panel
            :title="$t('Heightmap.BedMeshCalibrate')"
            :icon="mdiGrid"
            card-class="heightmap-calibrate-dialog"
            :margin-bottom="false">
            <template #buttons>
                <v-btn icon tile @click="closeDialog">
                    <v-icon>{{ mdiCloseThick }}</v-icon>
                </v-btn>
            </template>
            <v-card-text>
                <v-text-field
                    ref="input"
                    v-model="name"
                    :label="$t('Heightmap.Name')"
                    required
                    :rules="rules"
                    @update:error="
                        (newVal) => {
                            isInvalidName = newVal
                        }
                    "
                    @keyup.enter="calibrateMesh" />
                    
                <v-switch
                    v-model="useCustomBoundary"
                    label="Custom Mesh Boundary"
                    class="mt-2"
                ></v-switch>

                <heightmap-custom-mesh-map
                    v-if="useCustomBoundary"
                    @update:bounds="onBoundsUpdated"
                    @update:probes="onProbesUpdated"
                    @close="closeDialog"
                ></heightmap-custom-mesh-map>
            </v-card-text>
            <v-card-actions>
                <v-spacer />
                <v-btn text @click="closeDialog">{{ $t('Buttons.Cancel') }}</v-btn>
                <v-btn :disabled="isInvalidName" color="primary" text @click="calibrateMesh">
                    {{ $t('Heightmap.Calibrate') }}
                </v-btn>
            </v-card-actions>
        </panel>
    </v-dialog>
</template>
<script lang="ts">
import { Component, Mixins, Ref, VModel, Watch } from 'vue-property-decorator'
import BaseMixin from '@/components/mixins/base'
import { mdiCloseThick, mdiGrid } from '@mdi/js'
import HeightmapCustomMeshMap from './HeightmapCustomMeshMap.vue'

@Component({
    components: { HeightmapCustomMeshMap }
})
export default class HeightmapRenameProfileDialog extends Mixins(BaseMixin) {
    mdiCloseThick = mdiCloseThick
    mdiGrid = mdiGrid

    @VModel({ type: Boolean }) showDialog!: boolean
    @Ref() input!: HTMLInputElement

    isInvalidName = false
    name = ''

    useCustomBoundary = false
    customBounds = {
        xMin: 0,
        xMax: 200,
        yMin: 0,
        yMax: 200
    }
    probeCount = {
        x: 5,
        y: 5
    }

    rules = [
        (value: string) => !!value || this.$t('Heightmap.InvalidNameEmpty'),
        // eslint-disable-next-line no-control-regex
        (value: string) => value === value.replace(/[^\x00-\x7F]/g, '') || this.$t('Heightmap.InvalidNameAscii'),
    ]
    
    onBoundsUpdated(bounds: any) {
        this.customBounds = bounds
    }
    
    onProbesUpdated(probes: any) {
        this.probeCount = probes
    }

    calibrateMesh(): void {
        let gcode = `BED_MESH_CALIBRATE PROFILE="${this.name}"`
        
        if (this.useCustomBoundary) {
            gcode += ` MESH_MIN=${this.customBounds.xMin},${this.customBounds.yMin} MESH_MAX=${this.customBounds.xMax},${this.customBounds.yMax} PROBE_COUNT=${this.probeCount.x},${this.probeCount.y}`
        }

        this.$store.dispatch('server/addEvent', { message: gcode, type: 'command' })
        this.$socket.emit('printer.gcode.script', { script: gcode }, { loading: 'bedMeshCalibrate' })

        this.closeDialog()
    }

    closeDialog() {
        this.showDialog = false
    }

    @Watch('showDialog')
    onShowDialogChanged(newVal: boolean) {
        if (!newVal) return

        this.name = 'default'
        setTimeout(() => {
            this.input?.focus()
        })
    }
}
</script>
