<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'

const props = defineProps<{
  text: string
}>()

const containerRef = ref<HTMLElement | null>(null)
const rulerRef = ref<HTMLElement | null>(null)
const maxCols = ref(104)

let observer: ResizeObserver | null = null

function updateCols() {
  if (!containerRef.value || !rulerRef.value) return
  const chWidth = rulerRef.value.getBoundingClientRect().width / 10
  if (chWidth <= 0) return
  const totalCols = Math.floor(containerRef.value.clientWidth / chWidth)
  // Subtract 3 columns for the leading "// " prefix
  maxCols.value = Math.max(28, totalCols - 3)
}

const wrappedLines = computed(() => {
  const words = props.text.trim().split(/\s+/)
  const lines: string[] = []
  let current = ''

  for (const word of words) {
    if (!current) {
      current = word
    } else if (current.length + 1 + word.length <= maxCols.value) {
      current += ` ${word}`
    } else {
      lines.push(current)
      current = word
    }
  }
  if (current) {
    lines.push(current)
  }
  return lines
})

onMounted(() => {
  updateCols()
  if (typeof ResizeObserver !== 'undefined' && containerRef.value) {
    observer = new ResizeObserver(() => updateCols())
    observer.observe(containerRef.value)
  }
})

onBeforeUnmount(() => {
  observer?.disconnect()
})
</script>

<template>
  <div ref="containerRef" class="nik-comment-wrap">
    <span ref="rulerRef" class="nik-ch-ruler" aria-hidden="true">0000000000</span>
    <p v-for="(line, idx) in wrappedLines" :key="idx" class="nik-cm-line">// {{ line }}</p>
  </div>
</template>
