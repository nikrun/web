import { fileURLToPath, URL } from 'node:url'
import { defineConfig } from 'vitepress'

const siteTitle = 'Nikrun — Modern Toolchain for Free Pascal'
const siteDescription =
  'Modern, zero-config toolchain for Free Pascal: portable multi-arch SDKs, declarative nik.yaml builds, LSP, and VS Code support in one tool.'
const siteUrl = 'https://nikrun.dev'

const TAB_ICONS: Record<string, string> = {
  windows:
    '<svg class="tab-icon" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M0 3.449L9.75 2.1v9.451H0zm10.55-1.512L24 0v11.4h-13.45zM0 12.6h9.75v9.451L0 20.7zm10.55 0H24V24l-13.45-1.899z"/></svg>',
  linux:
    '<svg class="tab-icon" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 2C8.68 2 6.5 4.68 6.5 7.85c0 1.48.48 2.87 1.3 4.02l-1.8 3.59c-.43.76-.66 1.61-.66 2.48 0 3.06 3.16 5.41 7 5.41s7-2.35 7-5.41c0-.87-.23-1.72-.66-2.48l-1.8-3.59c.82-1.15 1.3-2.54 1.3-4.02C17.5 4.68 15.32 2 12 2zm-2 4.5a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm4 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm-5.8 6.8c.4-2.8 2.1-4.8 3.8-4.8s3.4 2 3.8 4.8c.1.9-.3 1.8-1.1 2.4-1 .8-1.7 1.1-2.7 1.1s-1.7-.3-2.7-1.1c-.8-.6-1.2-1.5-1.1-2.4z"/></svg>',
  macos:
    '<svg class="tab-icon" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 6.37c.62-.75 1.04-1.8 0.92-2.87-.9.04-2 .6-2.64 1.35-.57.65-.07 1.72.05 2.78 1.01.08 2.05-.51 2.67-1.26z"/></svg>'
}

export default defineConfig({
  title: 'Nikrun',
  description: siteDescription,
  srcDir: 'src',
  cleanUrls: true,
  appearance: 'force-dark',

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/favicon.svg' }],
    ['link', { rel: 'icon', type: 'image/x-icon', sizes: 'any', href: '/favicon.ico' }],
    ['link', { rel: 'apple-touch-icon', sizes: '180x180', href: '/apple-touch-icon.png' }],
    ['meta', { name: 'theme-color', content: '#0b0e14' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:site_name', content: 'Nikrun' }],
    ['meta', { property: 'og:title', content: siteTitle }],
    ['meta', { property: 'og:description', content: siteDescription }],
    ['meta', { property: 'og:url', content: `${siteUrl}/` }],
    ['meta', { property: 'og:image', content: `${siteUrl}/og-image.png` }],
    ['meta', { property: 'og:image:width', content: '1200' }],
    ['meta', { property: 'og:image:height', content: '630' }],
    ['meta', { property: 'og:image:alt', content: siteTitle }],
    ['meta', { name: 'twitter:card', content: 'summary_large_image' }],
    ['meta', { name: 'twitter:title', content: siteTitle }],
    ['meta', { name: 'twitter:description', content: siteDescription }],
    ['meta', { name: 'twitter:image', content: `${siteUrl}/og-image.png` }]
  ],

  markdown: {
    theme: 'github-dark',
    config(md) {
      const origCodeGroupOpen = md.renderer.rules['container_code-group_open']
      if (origCodeGroupOpen) {
        md.renderer.rules['container_code-group_open'] = (tokens, idx, options, env, self) =>
          origCodeGroupOpen(tokens, idx, options, env, self).replace(
            /<label data-title="([^"]*?)" for="([^"]*?)">([\s\S]*?)<\/label>/g,
            (_m, _dt, forId, raw) => {
              const title = raw.trim()
              const icon = TAB_ICONS[title.toLowerCase()]
              const esc = md.utils.escapeHtml(title)
              return `<label data-title="${esc}" title="${esc}" aria-label="${esc}" for="${forId}">${icon ?? esc}</label>`
            }
          )
      }
    }
  },

  vite: {
    resolve: {
      alias: [
        {
          find: /^.*\/VPNavBar\.vue$/,
          replacement: fileURLToPath(
            new URL('./theme/components/NikNavBar.vue', import.meta.url)
          )
        }
      ]
    }
  },

  themeConfig: {
    logo: {
      src: '/brand/nikrun-icon-dark-mono.svg',
      alt: 'Nikrun'
    },
    siteTitle: 'nikrun',
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Docs', link: '/docs/', activeMatch: '^/docs/' },
      { text: 'GitHub', link: 'https://github.com/nikrun' }
    ],
    sidebar: {
      '/docs/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Overview', link: '/docs/' },
            { text: 'Installation', link: '/docs/installation' },
            { text: 'Quickstart', link: '/docs/quickstart' }
          ]
        },
        {
          text: 'Core Workflow',
          items: [
            { text: 'SDK', link: '/docs/sdks' },
            { text: 'Project', link: '/docs/projects' },
            { text: 'Building', link: '/docs/builds' },
            { text: 'Packages', link: '/docs/packages' }
          ]
        },
        {
          text: 'Editor & Automation',
          items: [
            { text: 'VS Code & Language Server', link: '/docs/vscode-and-lsp' },
            { text: 'CI/CD & AI Agents', link: '/docs/ci-and-agents' }
          ]
        },
        {
          text: 'Reference',
          items: [
            { text: 'CLI', link: '/docs/reference/cli' },
            { text: 'Manifest & Lockfile', link: '/docs/reference/manifest' },
            { text: 'Paths & Environment', link: '/docs/reference/environment' },
            { text: 'FAQ & Licensing', link: '/docs/reference/faq' }
          ]
        }
      ]
    },
    footer: {
      message: 'Released under the GNU General Public License v3.0 or later (GPL-3.0-or-later).',
      copyright: 'Copyright © 2026 The Nikrun Contributors'
    },
    search: {
      provider: 'local'
    }
  }
})
