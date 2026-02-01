import Vue from 'vue'
import Component from 'vue-class-component'
import { backgroundSets } from '@/store/variables'

@Component
export default class ThemeMixin extends Vue {
    protected fgColor(alpha: number = 1, dark: boolean = this.$vuetify.theme.dark): string {
        const base = dark ? 255 : 0
        return `rgba(${base}, ${base}, ${base}, ${alpha})`
    }

    protected bgColor(alpha: number = 1) {
        return this.fgColor(alpha, !this.$vuetify.theme.dark)
    }

    get themeName() {
        return this.$store.getters['gui/theme']
    }

    get theme() {
        return this.$store.getters['gui/getTheme']
    }

    get themeMode() {
        return this.$store.state.gui.uiSettings.mode ?? 'dark'
    }

    get fgColorHi() {
        return this.fgColor(0.8)
    }

    get fgColorMid() {
        return this.fgColor(0.5)
    }

    get fgColorLow() {
        return this.fgColor(0.2)
    }

    get fgColorFaint() {
        return this.fgColor(0.1)
    }

    get machineButtonCol() {
        return this.$vuetify.theme.dark ? 'grey darken-3' : 'grey lighten-1'
    }

    get draggableBgStyle() {
        const col = this.$vuetify.theme.dark ? '#282828' : '#e7e7e7'
        return `background-color: ${col}`
    }

    get progressBarColor() {
        return this.$vuetify.theme.dark ? 'white' : 'primary'
    }

    get sidebarBgImage() {
        // Special handling for Royal variant (should be transparent/null)
        if (this.themeName === 'mainsail') {
            const variant = (this.$store.state.gui.uiSettings.backgroundVariant ?? 'standard')
            if (variant === 'royal') return null
        }

        // Special handling for Classic (should be clean/transparent)
        if (this.themeName === 'classic') return null

        if (this.theme.sidebarBackground?.show) {
            if (this.theme.sidebarBackground?.light && this.themeMode === 'light')
                return `/img/themes/sidebarBackground-${this.themeName}-light.png`

            return `/img/themes/sidebarBackground-${this.themeName}.png`
        }

        return this.$vuetify.theme.dark ? '/img/sidebar-background.svg' : '/img/sidebar-background-light.svg'
    }

    get sidebarLogo(): string {
        const url = this.$store.getters['files/getSidebarLogo']
        if (url !== '') return url

        // Special handling for Futuristic (mainsail) theme variants
        if (this.themeName === 'mainsail') {
            const variant = (this.$store.state.gui.uiSettings.backgroundVariant ?? 'standard') as keyof typeof backgroundSets
            const set = backgroundSets[variant] || backgroundSets['standard']

            return this.themeMode === 'light'
                ? `/img/themes/${set.logoLight}`
                : `/img/themes/${set.logoDark}`
        }

        // if no theme is set, return empty string to load the default logo
        if (!(this.theme.logo?.show ?? false)) return ''

        // return light logo if theme is light and sidebarLogo is set to both
        if (this.theme.logo?.light && this.themeMode === 'light')
            return `/img/themes/sidebarLogo-${this.themeName}-light.svg`

        // return dark/generic theme logo
        return `/img/themes/sidebarLogo-${this.themeName}.svg`
    }

    get mainBgImage() {
        // Only use uploaded background if the current theme is 'custom'
        if (this.themeName === 'custom') {
            const url = this.$store.getters['files/getMainBackground']
            if (url) return url
        }

        // Special handling for Futuristic (mainsail) theme variants
        if (this.themeName === 'mainsail') {
            const variant = (this.$store.state.gui.uiSettings.backgroundVariant ?? 'standard') as keyof typeof backgroundSets
            const set = backgroundSets[variant] || backgroundSets['standard']

            return this.themeMode === 'light'
                ? `/img/themes/${set.light}`
                : `/img/themes/${set.dark}`
        }

        if (!this.theme.mainBackground?.show) return null

        if (this.theme.mainBackground?.light && this.themeMode === 'light')
            return `/img/themes/mainBackground-${this.themeName}-light.png`

        return `/img/themes/mainBackground-${this.themeName}.png`
    }

    get themeCss() {
        if (!(this.theme.css ?? false)) return null

        return `/css/themes/${this.themeName}.css`
    }
}
