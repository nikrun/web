<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import NikAction from './NikAction.vue'
import NikCommentBlock from './NikCommentBlock.vue'
import NikLogo from './NikLogo.vue'
import NikTerminal from './NikTerminal.vue'

type OsBranch = 'windows' | 'unix' | 'other'

const detectedOs = ref<OsBranch>('unix')

const nikrunHome = computed(() =>
  detectedOs.value === 'windows' ? '%USERPROFILE%\\.nikrun' : '~/.nikrun'
)

const nikCache = computed(() =>
  detectedOs.value === 'windows' ? '.nik\\cache' : '.nik/cache'
)

const introComment =
  'Object Pascal compiles in milliseconds to lean, native binaries — yet setting up compilers, unit paths, and editor intelligence has traditionally been manual and fragile. Nikrun replaces that friction with one cohesive toolchain centered on the standalone nik CLI: a single dependency-free native binary uniting portable multi-arch Free Pascal SDKs, project scaffolding, declarative nik.yaml builds, and a built-in Language Server strictly in user scope.'

const installCommands = {
  unix: 'curl -fsSL https://nikrun.dev/install.sh | bash',
  windows: 'irm https://nikrun.dev/install.ps1 | iex'
}

onMounted(() => {
  if (typeof navigator === 'undefined') return
  const ua = `${navigator.platform || ''} ${navigator.userAgent || ''}`
  if (/Win/i.test(ua)) {
    detectedOs.value = 'windows'
  } else if (/Mac|Linux|X11/i.test(ua) && !/Android/i.test(ua)) {
    detectedOs.value = 'unix'
  } else {
    detectedOs.value = 'other'
  }
})
</script>

<template>
  <div class="nik-canvas">
    <!-- Main Single-Page Pascal Source Sheet -->
    <main class="nik-sheet">
      <!-- Program Header Line -->
      <header class="nik-header-line">
        <div class="nik-brand">
          <span class="nik-kw">program</span>
          <span><strong class="nik-brand-name">nikrun</strong><span class="nik-punct">;</span></span>
          <span class="nik-directive">&#123;$mode objfpc&#125;&#123;$H+&#125;</span>
        </div>
      </header>

      <!-- Program Header Comments, Uses Clause & Main Entry TOC -->
      <section class="nik-hero">
        <div class="nik-source-comments">
          <h1 class="nik-cm-line">
            // Modern, zero-config toolchain for Free Pascal. (<NikAction href="https://github.com/nikrun/">github.com/nikrun/</NikAction>)
          </h1>
          <p class="nik-cm-line" aria-hidden="true">//</p>
          <NikCommentBlock :text="introComment" />
        </div>

        <!-- uses cli, sdk, vscode; -->
        <div class="nik-uses-block">
          <div class="nik-code-kw-line"><span class="nik-kw">uses</span></div>
          <div class="nik-indent">
            <NikAction href="https://github.com/nikrun/cli" class="nik-ident">cli</NikAction><span class="nik-punct">, </span><NikAction href="https://github.com/nikrun/sdk" class="nik-ident">sdk</NikAction><span class="nik-punct">, </span><NikAction href="https://github.com/nikrun/vscode" class="nik-ident">vscode</NikAction><span class="nik-punct">;</span>
          </div>
        </div>

        <!-- Main Entry Block (Clickable Table of Contents) -->
        <nav class="nik-entry-block" aria-label="Program sections">
          <div class="nik-code-kw-line"><span class="nik-kw">begin</span></div>
          <div class="nik-block-body">
            <div>
              <NikAction href="#install" tooltip="Jump to procedure Install()" class="nik-fn">Install</NikAction><span class="nik-call">();</span>
            </div>
            <div>
              <NikAction href="#workflow" tooltip="Jump to procedure Workflow()" class="nik-fn">Workflow</NikAction><span class="nik-call">();</span>
            </div>
            <div>
              <NikAction href="#readdocs" tooltip="Jump to procedure ReadDocs()" class="nik-fn">ReadDocs</NikAction><span class="nik-call">();</span>
            </div>
          </div>
          <div class="nik-code-kw-line"><span class="nik-kw">end</span><span class="nik-punct">;</span></div>
        </nav>
      </section>

      <!-- ================================================================
           procedure Install();
           ================================================================ -->
      <section id="install" class="nik-proc">
        <h2 class="nik-proc-sig">
          <span class="nik-kw">procedure</span> <span class="nik-fn">Install</span><span class="nik-call">();</span>
        </h2>
        <div class="nik-code-kw-line"><span class="nik-kw">begin</span></div>

        <div class="nik-block-body">
          <p class="nik-inline-comment">
            // Isolated in {{ nikrunHome }} &mdash; no root/Admin, never touches global PATH or fpc.cfg
          </p>

          <div class="nik-ifdef-block">
            <div class="nik-code-kw-line"><span class="nik-directive">&#123;$IFDEF WINDOWS&#125;</span></div>
            <div class="nik-ifdef-branch" :class="{ 'is-inactive': detectedOs !== 'windows' }">
              <NikTerminal :cmd="installCommands.windows" tooltip="Click to copy Windows PowerShell command" />
            </div>

            <div class="nik-code-kw-line"><span class="nik-directive">&#123;$ELSEIF LINUX OR MACOS&#125;</span></div>
            <div class="nik-ifdef-branch" :class="{ 'is-inactive': detectedOs !== 'unix' }">
              <NikTerminal :cmd="installCommands.unix" tooltip="Click to copy Linux / macOS command" />
            </div>

            <div class="nik-code-kw-line"><span class="nik-directive">&#123;$ELSE&#125;</span></div>
            <div class="nik-ifdef-branch" :class="{ 'is-inactive': detectedOs !== 'other' }">
              <p class="nik-inline-comment">
                // Manual archives <NikAction href="https://github.com/nikrun/cli/releases">github.com/nikrun/cli/releases</NikAction>
              </p>
            </div>

            <div class="nik-code-kw-line"><span class="nik-directive">&#123;$ENDIF&#125;</span></div>
          </div>
        </div>

        <div class="nik-code-kw-line"><span class="nik-kw">end</span><span class="nik-punct">;</span></div>
      </section>

      <!-- ================================================================
           procedure Workflow();
           ================================================================ -->
      <section id="workflow" class="nik-proc">
        <h2 class="nik-proc-sig">
          <span class="nik-kw">procedure</span> <span class="nik-fn">Workflow</span><span class="nik-call">();</span>
        </h2>
        <div class="nik-code-kw-line"><span class="nik-kw">begin</span></div>

        <div class="nik-block-body">
          <p class="nik-inline-comment">// Side-by-side SHA-256 verified FPC SDKs (3.2.2..3.3.1, bundled RTL sources)</p>
          <NikTerminal cmd="nik sdk install 3.2.4" />
          <NikTerminal cmd="nik sdk install 3.3.1" />

          <div class="nik-blank-line" aria-hidden="true"></div>

          <p class="nik-inline-comment">// Scaffold nik.yaml &amp; compile hermetically via direct ppc* ({{ nikCache }})</p>
          <NikTerminal cmd="nik init hello" />
          <NikTerminal cmd="cd hello && nik build -p release" />

          <div class="nik-blank-line" aria-hidden="true"></div>

          <p class="nik-inline-comment">// CI/agent ready (--json, NO_COLOR) &amp; built-in Language Server</p>
          <NikTerminal cmd="nik build --clean --json" />
          <NikTerminal cmd="nik lsp --stdio" />
        </div>

        <div class="nik-code-kw-line"><span class="nik-kw">end</span><span class="nik-punct">;</span></div>
      </section>

      <!-- ================================================================
           procedure ReadDocs();
           ================================================================ -->
      <section id="readdocs" class="nik-proc">
        <h2 class="nik-proc-sig">
          <span class="nik-kw">procedure</span> <span class="nik-fn">ReadDocs</span><span class="nik-call">();</span>
        </h2>
        <div class="nik-code-kw-line"><span class="nik-kw">begin</span></div>

        <div class="nik-block-body">
          <p class="nik-inline-comment">// Guides, nik.yaml &amp; CLI reference</p>
          <div class="nik-terminal-stmt">
            <code class="nik-pas-stmt">
              <span class="nik-fn">OpenURL</span><span class="nik-punct">(</span><NikAction href="/docs/" tooltip="Open Nikrun Documentation" class="nik-str">'/docs/'</NikAction><span class="nik-punct">);</span>
            </code>
          </div>
          <div class="nik-terminal-stmt">
            <code class="nik-pas-stmt">
              <span class="nik-fn">OpenURL</span><span class="nik-punct">(</span><NikAction href="/docs/quickstart" tooltip="Open Quickstart" class="nik-str">'/docs/quickstart'</NikAction><span class="nik-punct">);</span>
            </code>
          </div>
          <div class="nik-terminal-stmt">
            <code class="nik-pas-stmt">
              <span class="nik-fn">OpenURL</span><span class="nik-punct">(</span><NikAction href="/docs/reference/manifest" tooltip="Open Manifest &amp; Lockfile Reference" class="nik-str">'/docs/reference/manifest'</NikAction><span class="nik-punct">);</span>
            </code>
          </div>
          <div class="nik-terminal-stmt">
            <code class="nik-pas-stmt">
              <span class="nik-fn">OpenURL</span><span class="nik-punct">(</span><NikAction href="/docs/reference/cli" tooltip="Open CLI Reference" class="nik-str">'/docs/reference/cli'</NikAction><span class="nik-punct">);</span>
            </code>
          </div>
        </div>

        <div class="nik-code-kw-line"><span class="nik-kw">end</span><span class="nik-punct">;</span></div>
      </section>

      <!-- Program End Line -->
      <footer class="nik-footer-line">
        <div><span class="nik-kw">end</span><span class="nik-punct">.</span></div>
        <div class="nik-colophon">
          <NikLogo class="nik-colophon-logo" />
        </div>
      </footer>
    </main>
  </div>
</template>
