<script setup lang="ts">
import DefaultTheme, { useSidebar } from 'vitepress/theme'
import NikThemeButton from './NikThemeButton.vue'

const { Layout } = DefaultTheme
const { hasSidebar } = useSidebar()
</script>

<template>
  <Layout>
    <template #doc-after>
      <div v-if="hasSidebar" class="nik-doc-theme-footer">
        <NikThemeButton />
      </div>
    </template>
  </Layout>
</template>

<style scoped>
.nik-doc-theme-footer {
  margin-top: 24px;
  padding-top: 16px;
  border-top: 1px solid var(--vp-c-divider);
  display: flex;
  justify-content: flex-end;
}
</style>
