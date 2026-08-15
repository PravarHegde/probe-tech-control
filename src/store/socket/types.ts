/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
export interface SocketState {
    hostname: string
    port: number
    path: string
    protocol: string
    reconnectInterval: number
    isConnected: boolean
    isConnecting: boolean
    connectingFailed: boolean
    connectionFailedMessage: string | null
    loadings: string[]
    initializationList: string[]
    connection_id: number | null
}
