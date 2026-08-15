/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
import { GetterTree } from 'vuex'
import { EditorState } from '@/store/editor/types'

export const getters: GetterTree<EditorState, any> = {
    getKlipperRestartMethod: (state, getters, rootState) => {
        return rootState.gui.editor?.klipperRestartMethod ?? 'FIRMWARE_RESTART'
    },
}
