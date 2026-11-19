<script setup lang="ts">
import { inBrowser, useData, useRoute } from 'vitepress'
import { nextTick, onMounted, onUnmounted, ref, watch } from 'vue'
import NikThemeButton from './NikThemeButton.vue'

const { theme, frontmatter } = useData()
const route = useRoute()
const footerEl = ref<HTMLElement | null>(null)

let resizeObserver: ResizeObserver | null = null
let rafId = 0

function updateFooterVisible() {
  if (!inBrowser) return
  if (!footerEl.value) {
    document.documentElement.style.setProperty('--nik-footer-visible', '0px')
    return
  }
  const rect = footerEl.value.getBoundingClientRect()
  const visible = Math.max(0, Math.min(rect.height, window.innerHeight - rect.top))
  document.documentElement.style.setProperty('--nik-footer-visible', `${Math.round(visible)}px`)
}

function scheduleUpdate() {
  if (!inBrowser || rafId) return
  rafId = window.requestAnimationFrame(() => {
    rafId = 0
    updateFooterVisible()
  })
}

onMounted(() => {
  updateFooterVisible()
  window.addEventListener('scroll', updateFooterVisible, { passive: true })
  window.addEventListener('resize', updateFooterVisible, { passive: true })
  if (typeof ResizeObserver !== 'undefined') {
    resizeObserver = new ResizeObserver(scheduleUpdate)
    resizeObserver.observe(document.body)
    if (footerEl.value) {
      resizeObserver.observe(footerEl.value)
    }
  }
})

onUnmounted(() => {
  if (!inBrowser) return
  if (rafId) {
    window.cancelAnimationFrame(rafId)
    rafId = 0
  }
  window.removeEventListener('scroll', updateFooterVisible)
  window.removeEventListener('resize', updateFooterVisible)
  resizeObserver?.disconnect()
  document.documentElement.style.removeProperty('--nik-footer-visible')
})

watch(
  () => route.path,
  () => {
    nextTick(scheduleUpdate)
  }
)
</script>

<template>
  <footer
    v-if="theme.footer && frontmatter.footer !== false"
    ref="footerEl"
    class="VPFooter"
  >
    <div class="container">
      <p v-if="theme.footer.message" class="message" v-html="theme.footer.message"></p>
      <p v-if="theme.footer.copyright" class="copyright" v-html="theme.footer.copyright"></p>
      <div class="footer-theme">
        <NikThemeButton />
      </div>
    </div>
  </footer>
</template>

<style scoped>
.VPFooter {
  position: relative;
  z-index: var(--vp-z-index-footer);
  width: 100%;
  border-top: 1px solid var(--vp-c-gutter);
  padding: 32px 24px;
  background-color: var(--vp-c-bg);
}

@media (min-width: 960px) {
  .VPFooter {
    z-index: calc(var(--vp-z-index-sidebar) + 1);
  }
}

.VPFooter :deep(a) {
  text-decoration-line: underline;
  text-underline-offset: 2px;
  transition: color 0.25s;
}

.VPFooter :deep(a:hover) {
  color: var(--vp-c-text-1);
}

@media (min-width: 768px) {
  .VPFooter {
    padding: 32px;
  }
}

.container {
  margin: 0 auto;
  max-width: var(--vp-layout-max-width);
  text-align: center;
}

.message,
.copyright {
  line-height: 24px;
  font-size: 14px;
  font-weight: 500;
  color: var(--vp-c-text-2);
}

.footer-theme {
  margin-top: 14px;
  display: flex;
  justify-content: center;
}
</style>
