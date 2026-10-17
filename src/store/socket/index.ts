/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
import { Module } from 'vuex'
import { SocketState } from '@/store/socket/types'
import { actions } from '@/store/socket/actions'
import { mutations } from '@/store/socket/mutations'
import { getters } from '@/store/socket/getters'
import { RootState } from '@/store/types'

export const getDefaultState = (): SocketState => {
    const isCloudRelay = typeof window !== 'undefined' && (
        window.location.hostname.includes('probharath.com') ||
        window.location.pathname.startsWith('/relay') ||
        (typeof document !== 'undefined' && document.cookie.includes('ptc_claim'))
    )
    const hostname = (import.meta.env.VUE_APP_HOSTNAME as string) || window.location.hostname
    const defaultPort = isCloudRelay
        ? (window.location.port ? Number(window.location.port) : (window.location.protocol === 'https:' ? 443 : 80))
        : 7125
    const port = import.meta.env.VUE_APP_PORT ? Number(import.meta.env.VUE_APP_PORT) : Number(defaultPort)
    const path = (import.meta.env.VUE_APP_PATH as string) || ''

    return {
        hostname,
        port,
        path,
        protocol: document.location.protocol === 'https:' ? 'wss' : 'ws',
        reconnectInterval: Number(import.meta.env.VUE_APP_RECONNECT_INTERVAL || 2000),
        isConnected: false,
        isConnecting: false,
        connectingFailed: false,
        connectionFailedMessage: null,
        loadings: [],
        initializationList: ['server'],
        connection_id: null,
    }
}

// initial state
const state = getDefaultState()

export const socket: Module<SocketState, RootState> = {
    namespaced: true,
    state,
    getters,
    actions,
    mutations,
}
