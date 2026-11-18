import { defineConfig } from 'vitepress'

const siteTitle = 'Nikrun — Modern Toolchain for Free Pascal'
const siteDescription =
  'Modern, zero-config toolchain for Free Pascal: portable multi-arch SDKs, declarative nik.yaml builds, LSP, and VS Code support in one tool.'
const siteUrl = 'https://nikrun.dev'

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
    theme: 'github-dark'
  },

  // Pre-configured for future documentation under src/docs/
  themeConfig: {
    logo: {
      light: '/brand/nikrun-icon-light.svg',
      dark: '/brand/nikrun-icon-dark-mono.svg',
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
    socialLinks: [
      { icon: 'github', link: 'https://github.com/nikrun' }
    ],
    search: {
      provider: 'local'
    }
  }
})
