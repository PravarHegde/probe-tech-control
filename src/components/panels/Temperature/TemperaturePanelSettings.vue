<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
<template>
    <v-menu :offset-y="true" :close-on-content-click="false" :title="$t('Panels.TemperaturePanel.SetupTemperatures')">
        <template #activator="{ on, attrs }">
            <v-btn icon tile v-bind="attrs" v-on="on">
                <v-icon small>{{ mdiCog }}</v-icon>
            </v-btn>
        </template>
        <v-list>
            <v-list-item class="minHeight36">
                <v-checkbox
                    v-model="boolTempchart"
                    class="mt-0"
                    hide-details
                    :label="$t('Panels.TemperaturePanel.ShowChart')" />
            </v-list-item>
            <v-list-item class="minHeight36">
                <v-checkbox
                    v-model="hideMcuHostSensors"
                    class="mt-0"
                    hide-details
                    :label="$t('Panels.TemperaturePanel.HideMcuHostSensors')" />
            </v-list-item>
            <v-list-item class="minHeight36">
                <v-checkbox
                    v-model="hideMonitors"
                    class="mt-0"
                    hide-details
                    :label="$t('Panels.TemperaturePanel.HideMonitors')" />
            </v-list-item>
            <v-list-item class="minHeight36">
                <v-checkbox
                    v-model="autoscaleTempchart"
                    class="mt-0"
                    hide-details
                    :label="$t('Panels.TemperaturePanel.AutoscaleChart')" />
            </v-list-item>
            <v-list-item class="minHeight36 px-4 py-2 mt-2">
                <v-text-field
                    v-model.number="idleTimeoutRegular"
                    type="number"
                    dense
                    outlined
                    hide-details
                    label="Regular Timeout (seconds)" />
            </v-list-item>
            <v-list-item class="minHeight36 px-4 py-2">
                <v-text-field
                    v-model.number="idleTimeoutLocked"
                    type="number"
                    dense
                    outlined
                    hide-details
                    label="Locked Timeout (seconds)" />
            </v-list-item>
        </v-list>
    </v-menu>
</template>

<script lang="ts">
import Component from 'vue-class-component'
import { Mixins } from 'vue-property-decorator'
import BaseMixin from '@/components/mixins/base'
import { mdiCog } from '@mdi/js'

@Component
export default class TemperaturePanelSettings extends Mixins(BaseMixin) {
    mdiCog = mdiCog

    get boolTempchart(): boolean {
        return this.$store.state.gui.view.tempchart.boolTempchart ?? false
    }

    set boolTempchart(newVal: boolean) {
        this.$store.dispatch('gui/saveSetting', { name: 'view.tempchart.boolTempchart', value: newVal })
    }

    get autoscaleTempchart(): boolean {
        return this.$store.state.gui.view.tempchart.autoscale ?? false
    }

    set autoscaleTempchart(newVal: boolean) {
        this.$store.dispatch('gui/saveSetting', { name: 'view.tempchart.autoscale', value: newVal })
    }

    get hideMcuHostSensors(): boolean {
        return this.$store.state.gui.view.tempchart.hideMcuHostSensors ?? false
    }

    set hideMcuHostSensors(newVal: boolean) {
        this.$store.dispatch('gui/saveSetting', { name: 'view.tempchart.hideMcuHostSensors', value: newVal })
    }

    get hideMonitors(): boolean {
        return this.$store.state.gui.view.tempchart.hideMonitors ?? false
    }

    set hideMonitors(newVal: boolean) {
        this.$store.dispatch('gui/saveSetting', { name: 'view.tempchart.hideMonitors', value: newVal })
    }

    get idleTimeoutRegular(): number {
        return this.$store.state.gui.view.tempchart.idleTimeoutRegular ?? 600
    }

    set idleTimeoutRegular(newVal: number) {
        this.$store.dispatch('gui/saveSetting', { name: 'view.tempchart.idleTimeoutRegular', value: newVal })
    }

    get idleTimeoutLocked(): number {
        return this.$store.state.gui.view.tempchart.idleTimeoutLocked ?? 86400
    }

    set idleTimeoutLocked(newVal: number) {
        this.$store.dispatch('gui/saveSetting', { name: 'view.tempchart.idleTimeoutLocked', value: newVal })
    }
}
</script>
