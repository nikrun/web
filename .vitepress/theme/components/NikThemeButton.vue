<script lang="ts" setup>
import { inBrowser, useData } from 'vitepress'
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'

type ThemeMode = 'auto' | 'light' | 'dark'

const STORAGE_KEY = 'vitepress-theme-appearance'

const { isDark } = useData()
const mode = ref<ThemeMode>('auto')
const systemIsDark = ref(false)

function normalizeMode(raw: string | null): ThemeMode {
  return raw === 'light' || raw === 'dark' ? raw : 'auto'
}

const cycleOrder = computed<ThemeMode[]>(() =>
  systemIsDark.value ? ['auto', 'light', 'dark'] : ['auto', 'dark', 'light']
)

const nextMode = computed<ThemeMode>(() => {
  const order = cycleOrder.value
  return order[(order.indexOf(mode.value) + 1) % order.length]
})

const labels: Record<ThemeMode, string> = {
  auto: 'System',
  light: 'Light',
  dark: 'Dark'
}

const currentLabel = computed(() => labels[mode.value])
const buttonTitle = computed(
  () => `Theme: ${labels[mode.value]} — click to switch to ${labels[nextMode.value]}`
)

function syncThemeColor(dark: boolean) {
  if (!inBrowser) return
  let meta = document.querySelector<HTMLMetaElement>('meta[name="theme-color"][data-nik-active]')
  if (!meta) {
    meta = document.createElement('meta')
    meta.name = 'theme-color'
    meta.setAttribute('data-nik-active', '')
    document.head.appendChild(meta)
  }
  meta.content = dark ? '#0b0e14' : '#ffffff'
}

function cycleTheme() {
  if (!inBrowser) return
  const next = nextMode.value
  const oldValue = window.localStorage.getItem(STORAGE_KEY)
  window.localStorage.setItem(STORAGE_KEY, next)
  mode.value = next
  window.dispatchEvent(
    new StorageEvent('storage', {
      key: STORAGE_KEY,
      oldValue,
      newValue: next,
      storageArea: window.localStorage
    })
  )
}

let mql: MediaQueryList | null = null

function onMediaChange(e: MediaQueryListEvent) {
  systemIsDark.value = e.matches
}

function onStorageChange(e: StorageEvent) {
  if (e.key === null || e.key === STORAGE_KEY) {
    mode.value = normalizeMode(e.newValue)
  }
}

onMounted(() => {
  mode.value = normalizeMode(window.localStorage.getItem(STORAGE_KEY))
  mql = window.matchMedia('(prefers-color-scheme: dark)')
  systemIsDark.value = mql.matches
  mql.addEventListener('change', onMediaChange)
  window.addEventListener('storage', onStorageChange)
  syncThemeColor(isDark.value)
})

onUnmounted(() => {
  mql?.removeEventListener('change', onMediaChange)
  if (inBrowser) {
    window.removeEventListener('storage', onStorageChange)
  }
})

watch(isDark, (dark) => {
  syncThemeColor(dark)
})
</script>

<template>
  <button
    type="button"
    class="nik-theme-button"
    :title="buttonTitle"
    :aria-label="buttonTitle"
    @click="cycleTheme"
  >
    <svg
      v-if="mode === 'auto'"
      class="nik-theme-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <rect x="2" y="3" width="20" height="14" rx="2" />
      <path d="M8 21h8" />
      <path d="M12 17v4" />
    </svg>
    <svg
      v-else-if="mode === 'light'"
      class="nik-theme-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <circle cx="12" cy="12" r="4" />
      <path d="M12 2v2" />
      <path d="M12 20v2" />
      <path d="m4.93 4.93 1.41 1.41" />
      <path d="m17.66 17.66 1.41 1.41" />
      <path d="M2 12h2" />
      <path d="M20 12h2" />
      <path d="m6.34 17.66-1.41 1.41" />
      <path d="m19.07 4.93-1.41 1.41" />
    </svg>
    <svg
      v-else
      class="nik-theme-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
    </svg>
    <span>Theme: {{ currentLabel }}</span>
  </button>
</template>

<style scoped>
.nik-theme-button {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  height: 28px;
  padding: 0 10px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background-color: var(--vp-c-bg-alt);
  color: var(--vp-c-text-2);
  font-family: var(--vp-font-family-mono);
  font-size: 12px;
  line-height: 1;
  cursor: pointer;
  transition:
    color 0.2s,
    border-color 0.2s,
    background-color 0.2s;
}

.nik-theme-button:hover {
  border-color: var(--vp-c-brand-1);
  background-color: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
}

.nik-theme-button:focus-visible {
  outline: 2px solid var(--vp-c-brand-1);
  outline-offset: 2px;
}

.nik-theme-icon {
  width: 14px;
  height: 14px;
  flex-shrink: 0;
}
</style>
