<script lang="ts" setup>
import VPNavBarHamburger from 'vitepress/dist/client/theme-default/components/VPNavBarHamburger.vue'
import VPNavBarMenu from 'vitepress/dist/client/theme-default/components/VPNavBarMenu.vue'
import VPNavBarSearch from 'vitepress/dist/client/theme-default/components/VPNavBarSearch.vue'
import VPNavBarTitle from 'vitepress/dist/client/theme-default/components/VPNavBarTitle.vue'

defineProps<{
  isScreenOpen: boolean
}>()

defineEmits<{
  (e: 'toggle-screen'): void
}>()
</script>

<template>
  <div class="VPNavBar">
    <div class="wrapper">
      <div class="container">
        <VPNavBarTitle class="nav-title" />
        <VPNavBarSearch class="nav-search" />
        <div class="nav-actions">
          <VPNavBarMenu />
          <VPNavBarHamburger :active="isScreenOpen" @click="$emit('toggle-screen')" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.VPNavBar {
  position: relative;
  height: var(--vp-nav-height);
  background-color: var(--vp-nav-bg-color);
  border-bottom: 1px solid var(--vp-c-divider);
  pointer-events: auto;
  white-space: nowrap;
}

.wrapper {
  height: 100%;
  padding: 0 8px 0 24px;
}

@media (min-width: 768px) {
  .wrapper {
    padding: 0 32px;
  }
}

.container {
  display: flex;
  align-items: center;
  margin: 0 auto;
  max-width: calc(var(--vp-layout-max-width) - 64px);
  height: 100%;
}

@media (min-width: 768px) {
  .container {
    display: grid;
    grid-template-columns: 1fr auto 1fr;
    column-gap: 16px;
  }
}

.nav-title {
  flex-shrink: 0;
  justify-self: start;
}

.VPNavBar .nav-title :deep(.title) {
  height: calc(var(--vp-nav-height) - 1px);
  border-bottom: none;
}

.nav-search {
  margin-left: auto;
}

@media (min-width: 768px) {
  .VPNavBar .nav-search {
    margin-left: 0;
    justify-self: center;
    flex-grow: 0;
    padding-left: 0;
  }

  .VPNavBar .nav-search :deep(.DocSearch-Button) {
    width: 220px;
    height: 36px;
    border-radius: 6px;
    border: 1px solid var(--vp-c-divider);
    background-color: var(--vp-c-bg-alt);
    justify-content: space-between;
  }

  .VPNavBar .nav-search :deep(.DocSearch-Button:hover) {
    border-color: var(--vp-c-brand-1);
    background-color: var(--vp-c-bg-soft);
  }
}

@media (min-width: 960px) {
  .VPNavBar .nav-search :deep(.DocSearch-Button) {
    width: 280px;
  }
}

.nav-actions {
  display: flex;
  align-items: center;
  justify-self: end;
  column-gap: 0.5rem;
}
</style>
