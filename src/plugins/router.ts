/* 
==============================================================================
PROBHARATH TECHNOLOGIES PVT LTD
A Probharath Technologies Product
============================================================================== 
*/
import VueRouter from 'vue-router'
import Vue from 'vue'
import routes from '@/routes'

Vue.use(VueRouter)
const router = new VueRouter({
    base: import.meta.env.BASE_URL,
    mode: 'history',
    routes,
})

router.beforeEach((to, from, next) => {
    if (!to.matched || to.matched.length === 0 || to.path === '/relay' || to.path === '/relay/') {
        next({ path: '/', replace: true })
    } else {
        next()
    }
})

export default router
