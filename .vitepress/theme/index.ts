import type { Theme } from 'vitepress'
import DefaultTheme from 'vitepress/theme'
import NikLayout from './components/NikLayout.vue'
import './custom.css'

export default {
  extends: DefaultTheme,
  Layout: NikLayout
} satisfies Theme
