<script setup lang="ts">
import { useData } from 'vitepress'
import { useSidebar } from 'vitepress/theme'
import NikThemeButton from './NikThemeButton.vue'

const { theme, frontmatter } = useData()
const { hasSidebar } = useSidebar()
</script>

<template>
  <footer
    v-if="theme.footer && frontmatter.footer !== false"
    class="VPFooter"
    :class="{ 'has-sidebar': hasSidebar }"
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
  z-index: calc(var(--vp-z-index-footer) + 1);
  border-top: 1px solid var(--vp-c-gutter);
  padding: 32px 24px;
  background-color: var(--vp-c-bg);
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

@media (min-width: 960px) {
  .VPFooter.has-sidebar {
    padding-left: calc(var(--vp-sidebar-width) + 32px);
    padding-right: 32px;
  }
}

@media (min-width: 1440px) {
  .VPFooter.has-sidebar {
    padding-left: calc((100% - var(--vp-layout-max-width)) / 2 + var(--vp-sidebar-width) + 32px);
    padding-right: calc((100% - var(--vp-layout-max-width)) / 2 + 32px);
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
