import { defineConfig } from 'vitepress'

const faviconSvg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect width="32" height="32" fill="#0b0f14"/><rect x="1.5" y="1.5" width="29" height="29" fill="none" stroke="#38bdf8" stroke-width="2"/><text x="16" y="22" font-family="monospace" font-size="18" font-weight="bold" fill="#facc15" text-anchor="middle">n;</text></svg>`

export default defineConfig({
  title: 'Nikrun',
  description:
    'Modern, zero-config toolchain for Free Pascal: portable multi-arch SDKs, declarative nik.yaml builds, LSP, and VS Code support in one tool.',
  srcDir: 'src',
  cleanUrls: true,
  appearance: 'force-dark',

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: `data:image/svg+xml,${encodeURIComponent(faviconSvg)}` }],
    ['meta', { name: 'theme-color', content: '#0b0e14' }]
  ],

  markdown: {
    theme: 'github-dark'
  },

  // Pre-configured for future documentation under src/docs/
  themeConfig: {
    siteTitle: 'nikrun',
    nav: [
      { text: 'Home', link: '/' },
      // Uncomment when publishing documentation:
      // { text: 'Docs', link: '/docs/' },
      { text: 'GitHub', link: 'https://github.com/nikrun/cli' }
    ],
    sidebar: {
      '/docs/': [
        {
          text: 'Documentation',
          items: [
            { text: 'Overview', link: '/docs/' }
          ]
        }
      ]
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/nikrun/cli' }
    ],
    search: {
      provider: 'local'
    }
  }
})
