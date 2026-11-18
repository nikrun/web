<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  href?: string
  copy?: string
  tooltip?: string
}>()

const isExternal = computed(() => Boolean(props.href && /^https?:\/\//i.test(props.href)))

const resolvedTooltip = computed(() => {
  if (props.tooltip) return props.tooltip
  if (props.copy !== undefined) return 'Click to copy to clipboard'
  if (props.href?.startsWith('#')) return `Jump to ${props.href.slice(1)}()`
  if (props.href) return `Open ${props.href.replace(/^https?:\/\//i, '')}`
  return ''
})

async function onClick() {
  if (props.copy !== undefined) {
    try {
      await navigator.clipboard.writeText(props.copy)
    } catch (_) {
      // ignore clipboard errors in restricted contexts
    }
  }
}
</script>

<template>
  <a
    v-if="href"
    :href="href"
    :target="isExternal ? '_blank' : undefined"
    :rel="isExternal ? 'noopener' : undefined"
    :title="resolvedTooltip"
    class="nik-action"
  ><slot /></a>
  <button
    v-else
    type="button"
    :title="resolvedTooltip"
    class="nik-action"
    @click="onClick"
  ><slot /></button>
</template>
