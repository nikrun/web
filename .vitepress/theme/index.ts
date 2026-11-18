import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import NikHome from './components/NikHome.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('NikHome', NikHome)
  }
} satisfies Theme
