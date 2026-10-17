/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
import router from '@/plugins/router'
import { ActionTree } from 'vuex'
import { ConfigJson, RootState } from './types'

export const actions: ActionTree<RootState, RootState> = {
    switchToDashboard() {
        if (router.currentRoute.fullPath !== '/') router.push('/')
    },

    changePrinter({ dispatch, getters }, payload) {
        dispatch('files/reset')
        dispatch('gui/reset')
        dispatch('printer/reset')
        dispatch('server/reset')
        dispatch('socket/reset')

        const printerSocket = getters['farm/' + payload.printer + '/getSocketData']

        dispatch('socket/setSocket', {
            hostname: printerSocket.hostname,
            port: printerSocket.port,
            path: printerSocket.path,
        })
    },

    setNaviDrawer({ commit }, payload) {
        commit('setNaviDrawer', payload)
    },

    /**
     * This function will parse the config.json content and config mainsail
     */
    async importConfigJson({ commit }, payload: ConfigJson) {
        type RootStateInstancesDbType = 'moonraker' | 'browser' | 'json'
        let instancesDB: RootStateInstancesDbType = payload.instancesDB ?? 'moonraker'
        if (import.meta.env.VUE_APP_INSTANCES_DB)
            instancesDB = import.meta.env.VUE_APP_INSTANCES_DB as RootStateInstancesDbType

        if (instancesDB !== 'moonraker') {
            commit('setInstancesDB', instancesDB)

            if (
                instancesDB === 'json' &&
                'instances' in payload &&
                Array.isArray(payload.instances) &&
                payload.instances.length
            ) {
                commit('setConfigInstances', payload.instances)
            }

            return
        }

        const isCloudRelay = typeof window !== 'undefined' && (
            window.location.hostname.includes('probharath.com') ||
            window.location.pathname.startsWith('/relay') ||
            (typeof document !== 'undefined' && document.cookie.includes('ptc_claim'))
        )

        if (payload.hostname && !isCloudRelay) commit('socket/setData', { hostname: payload.hostname })
        if (payload.port && !isCloudRelay) commit('socket/setData', { port: parseInt(payload.port.toString()) })
        if (payload.path && !isCloudRelay) commit('socket/setData', { route_prefix: payload.path })
    },
}
