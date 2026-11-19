<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://nikrun.dev/brand/nikrun-lockup-dark-mono.svg">
    <img alt="Nikrun" src="https://nikrun.dev/brand/nikrun-lockup-light.svg" height="52">
  </picture>
</p>

# Nikrun Website & Docs

[![Deploy GitHub Pages](https://github.com/nikrun/web/actions/workflows/pages.yml/badge.svg)](https://github.com/nikrun/web/actions/workflows/pages.yml)
[![License: GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](./LICENSE)
[![Website: nikrun.dev](https://img.shields.io/badge/website-nikrun.dev-0b0e14)](https://nikrun.dev)

> **Official [nikrun.dev](https://nikrun.dev) landing page, documentation hub, and cross-platform CLI installer endpoints.**

[nikrun.dev](https://nikrun.dev) · [`nik` CLI](https://github.com/nikrun/cli) · [Free Pascal SDKs](https://github.com/nikrun/sdk) · [VS Code Extension](https://github.com/nikrun/vscode) · **[Website & Docs](https://github.com/nikrun/web)** · [Brand Assets](https://github.com/nikrun/brand) · [Build Library](https://github.com/nikrun/build-lib)

---

**Nikrun Website & Docs** powers **[nikrun.dev](https://nikrun.dev)** — combining the project landing page, multi-page user and reference documentation, canonical brand assets (`https://nikrun.dev/brand/*`), and unattended user-scope installer scripts for the **`nik` CLI**, built with **[VitePress](https://vitepress.dev/)**.

---

## Overview

- **Landing Page & Documentation (`src/`):** Unified VitePress landing page (`src/index.md`) sharing the same header, navigation, and design language as the user guides and CLI/manifest reference pages (`src/docs/`).
- **Hosted CLI Install & Uninstall Endpoints (`src/public/`):** Published directly at the `https://nikrun.dev/` root:
  - **`install.ps1` / `install.sh`:** Resolves releases from [`nikrun/cli`](https://github.com/nikrun/cli) (`stable` or `insider` channel, optional pinned version), verifies SHA-256 checksums against `manifest.json`, extracts `nik` strictly in user scope (`~/.nikrun/bin` / `%USERPROFILE%\.nikrun\bin`), updates user `PATH`, and registers `Nikrun CLI` under Windows Installed Apps (`HKCU`).
  - **`uninstall.ps1` / `uninstall.sh`:** Stops running `nik` processes (such as `nik lsp`), removes the CLI binary, cleans up user `PATH` and Windows Registry entries, and supports `-Purge` / `--purge` or `-KeepData` / `--keep-data`.
- **Canonical Brand Hosting (`brand/` -> `src/public/brand/`):** Synchronizes vector and raster assets from the [`nikrun/brand`](https://github.com/nikrun/brand) submodule via `scripts/sync-brand.mjs`.

---

## Quick Start

### End-User CLI Installation (`nikrun.dev`)

```powershell
# Windows (PowerShell) — supports $env:NIKRUN_CHANNEL = 'insider' and $env:NIKRUN_VERSION
irm https://nikrun.dev/install.ps1 | iex

# Uninstall on Windows
irm https://nikrun.dev/uninstall.ps1 | iex
```

```bash
# Linux & macOS — supports -c|--channel insider, -v|--version <ver>, --no-modify-path
curl -fsSL https://nikrun.dev/install.sh | bash

# Uninstall on Linux & macOS
curl -fsSL https://nikrun.dev/uninstall.sh | bash
```

### Local Website Development

```bash
git submodule update --init --recursive
npm install       # Install dependencies & sync brand assets
npm run dev       # Start local VitePress dev server with HMR (http://localhost:5173)
npm run build     # Build static production site into .vitepress/dist/
npm run preview   # Preview production build locally
```

---

## Repository Structure

```text
web/
├── .github/
│   └── workflows/pages.yml        # Automated VitePress build & GitHub Pages deployment
├── .vitepress/
│   ├── config.mts                 # Site navigation, sidebar, metadata & VitePress config
│   └── theme/                     # Custom Nikrun theme components & stylesheet
├── brand/                         # Shared Nikrun brand & icon assets (Git submodule)
├── scripts/
│   └── sync-brand.mjs             # Copies canonical brand assets into src/public/
└── src/
    ├── index.md                   # nikrun.dev landing page
    ├── docs/                      # User guides (installation, SDKs, nik.yaml, packages, LSP, CI)
    │   └── reference/             # Detailed CLI & manifest reference documentation
    └── public/                    # Root static assets (CNAME, favicons, install/uninstall scripts)
```

---

## License

Copyright (c) 2026 The Nikrun Contributors.

Licensed under the **GNU General Public License v3.0 or later** (`GPL-3.0-or-later`) — see [LICENSE](./LICENSE).
