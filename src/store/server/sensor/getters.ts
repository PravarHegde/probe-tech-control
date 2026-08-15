/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
import { GetterTree } from 'vuex'
import { ServerSensorState } from '@/store/server/sensor/types'

// eslint-disable-next-line
export const getters: GetterTree<ServerSensorState, any> = {
    getSensors: (state) => {
        return Object.keys(state.sensors)
    },
}
