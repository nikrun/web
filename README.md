# Nikrun Website & Documentation (`nikrun/web`)

Static website, CLI installer endpoints, and future documentation hub for **[Nikrun](https://nikrun.dev)**, built with **[VitePress](https://vitepress.dev/)**.

## Quick Commands

```bash
npm install       # Install dependencies
npm run dev       # Start local dev server with HMR (http://localhost:5173)
npm run build     # Build static site into .vitepress/dist/
npm run preview   # Preview production build locally
```

## Hosted Install & Uninstall Scripts (`src/public/`)

VitePress publishes static files from `src/public/` directly to the site root (`https://nikrun.dev/...`):

- `install.ps1` / `install.sh` — Resolves releases directly from `github.com/nikrun/cli` (`stable` or `insider` channel, optional specific version), verifies SHA-256 against `manifest.json`, extracts `nik` into `~/.nikrun/bin` (`%USERPROFILE%\.nikrun\bin`), configures user-scope `PATH`, and registers `Nikrun CLI` under Windows Installed Apps (`HKCU`).
  - Windows: `irm https://nikrun.dev/install.ps1 | iex` (supports `$env:NIKRUN_CHANNEL = 'insider'` / `-Channel insider`, `$env:NIKRUN_VERSION` / `-Version`)
  - Linux / macOS: `curl -fsSL https://nikrun.dev/install.sh | bash` (supports `-c|--channel insider`, `-v|--version <ver>`, `--no-modify-path`)
- `uninstall.ps1` / `uninstall.sh` — Stops running `nik` processes (e.g. `nik lsp`), removes the CLI binary, cleans up user `PATH` and Windows Registry entries, and interactively asks whether to also remove installed SDKs/config in `.nikrun` (or pass `-Purge` / `--purge` or `-KeepData` / `--keep-data`).
  - Windows: `irm https://nikrun.dev/uninstall.ps1 | iex`
  - Linux / macOS: `curl -fsSL https://nikrun.dev/uninstall.sh | bash`

## Adding Documentation Later

Markdown pages live in `src/`. To publish multi-page documentation later:

1. Create Markdown files under `src/docs/` (e.g. `src/docs/index.md`, `src/docs/nik-yaml.md`).
2. Uncomment the `Docs` nav item and add sidebar links in `.vitepress/config.mts`.
