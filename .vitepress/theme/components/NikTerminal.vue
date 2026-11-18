<script setup lang="ts">
import NikAction from './NikAction.vue'

defineProps<{
  cmd: string
  tooltip?: string
}>()
</script>

<template>
  <div class="nik-terminal-stmt">
    <code class="nik-pas-stmt">
      <span class="nik-fn">Terminal</span><span class="nik-punct">(</span><NikAction
        :copy="cmd"
        :tooltip="tooltip || `Click to copy: ${cmd}`"
        class="nik-str"
      >'{{ cmd }}'</NikAction><span class="nik-punct">);</span>
    </code>
  </div>
</template>
