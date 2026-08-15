<!-- 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
-->
<template>
    <panel
        title="Probharath Machines"
        card-class="probharath-boards-panel"
        :icon="mdiPrinter3d"
        :collapsible="true">
        <v-card-text>
            <v-row>
                <v-col cols="12" sm="6" md="6" lg="6" v-for="(board, index) in boards" :key="index">
                    <v-card outlined class="d-flex flex-column" style="height: 100%">
                        <v-card-title class="text-subtitle-1 font-weight-bold">
                            <v-icon left color="primary">{{ board.icon }}</v-icon>
                            {{ board.name }}
                        </v-card-title>
                        <v-card-text class="flex-grow-1">
                            {{ board.description }}
                        </v-card-text>
                        <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn text color="primary" :href="board.downloadLink" :download="board.filename">
                                <v-icon left>{{ mdiDownload }}</v-icon>
                                Download Config
                            </v-btn>
                        </v-card-actions>
                    </v-card>
                </v-col>
            </v-row>
        </v-card-text>
    </panel>
</template>

<script lang="ts">
import { Component, Mixins } from 'vue-property-decorator'
import BaseMixin from '@/components/mixins/base'
import Panel from '@/components/ui/Panel.vue'
import { mdiPrinter3d, mdiDownload, mdiStar, mdiCogs, mdiServerNetwork } from '@mdi/js'

@Component({
    components: { Panel },
})
export default class ProbharathBoardsPanel extends Mixins(BaseMixin) {
    mdiPrinter3d = mdiPrinter3d
    mdiDownload = mdiDownload
    
    get boards() {
        return [
            {
                name: 'Probharath Auro O Lite',
                description: 'Ultra-budget model with standalone drivers, I2C display, and encoder support.',
                icon: mdiPrinter3d,
                downloadLink: '/Machine configs/probharath_machines/Auro_O/Lite/printer.cfg',
                filename: 'printer.cfg'
            },
            {
                name: 'Probharath Auro O Standard',
                description: 'Balanced model featuring a shared UART bus and I2C display header.',
                icon: mdiPrinter3d,
                downloadLink: '/Machine configs/probharath_machines/Auro_O/Standard/printer.cfg',
                filename: 'printer.cfg'
            },
            {
                name: 'Probharath Auro O Pure',
                description: 'Single-nozzle model with 100% Dedicated UART pins for maximum bandwidth.',
                icon: mdiPrinter3d,
                downloadLink: '/Machine configs/probharath_machines/Auro_O/Pure/printer.cfg',
                filename: 'printer.cfg'
            },
            {
                name: 'Probharath Auro O Pro',
                description: 'Maximum performance dual-nozzle IDEX capable model.',
                icon: mdiPrinter3d,
                downloadLink: '/Machine configs/probharath_machines/Auro_O/Pro/printer.cfg',
                filename: 'printer.cfg'
            },
            {
                name: 'Probharath Elite O',
                description: 'Premium 3D printer board with high-end features and TMC2209s.',
                icon: mdiStar,
                downloadLink: '/Machine configs/probharath_machines/probharath_elite_o.cfg',
                filename: 'probharath_elite_o.cfg'
            },
            {
                name: 'Probharath Titan CNC O',
                description: 'Heavy duty controller for CNC and Lathe with NEMA 34 drivers.',
                icon: mdiCogs,
                downloadLink: '/Machine configs/probharath_machines/probharath_titan_cnc_o.cfg',
                filename: 'probharath_titan_cnc_o.cfg'
            },
            {
                name: 'Probharath Matrixs',
                description: 'Advanced dual MCU CAN bus system for maximum expandability.',
                icon: mdiServerNetwork,
                downloadLink: '/Machine configs/probharath_machines/probharath_matrixs.cfg',
                filename: 'probharath_matrixs.cfg'
            }
        ]
    }
}
</script>

<style scoped>
.probharath-boards-panel {
    margin-bottom: 12px;
}
</style>
