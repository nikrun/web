---
layout: home
title: Nikrun — Modern Toolchain for Free Pascal

hero:
  name: Nikrun
  text: Modern, zero-config toolchain for Free Pascal.
  tagline: One standalone native binary (<code>nik</code>) uniting portable multi-arch Free Pascal SDKs, declarative builds (<code>nik.yaml</code>), decentralized packages, and a built-in Language Server strictly in user scope.
  actions:
    - theme: brand
      text: Quickstart
      link: /docs/quickstart
    - theme: alt
      text: Documentation
      link: /docs/
    - theme: alt
      text: GitHub
      link: https://github.com/nikrun

features:
  - title: User-Scope Isolation
    details: Installs strictly into <code>~/.nikrun</code> with no administrator or root privileges, never altering global system <code>PATH</code> settings or <code>/etc/fpc.cfg</code> files.
    link: /docs/installation
    linkText: Installation
  - title: Multi-Version & Multi-Arch SDKs
    details: Install SHA-256-verified Free Pascal <code>3.2.2</code>, <code>3.2.4</code>, and nightly <code>3.3.1</code> archives side by side in seconds across Windows, Linux, and macOS (<code>x86_64</code> & <code>aarch64</code>).
    link: /docs/sdks
    linkText: SDK Guide
  - title: Declarative Builds
    details: Configure programs, shared libraries, and packages in one clean <code>nik.yaml</code> manifest with exact compiler pinning, profiles, OS/CPU overlays, and direct <code>ppc*</code> execution.
    link: /docs/projects
    linkText: Projects & Builds
  - title: Decentralized Packages
    details: Resolve Git repository, archive URL, and local path dependencies via Minimal Version Selection with cryptographic SHA-256 lockfiles (<code>nik.lock</code>) and immutable caching.
    link: /docs/packages
    linkText: Package Management
  - title: Language Server & VS Code
    details: Built-in Language Server (<code>nik lsp</code>) reading <code>nik.yaml</code> and bundled RTL sources directly for live diagnostics on unsaved buffers, Go to Definition, and status-bar switchers.
    link: /docs/vscode-and-lsp
    linkText: VS Code & LSP
  - title: One Native Binary, CI & Agent Ready
    details: Written in pure Object Pascal with zero external runtime dependencies. Provides structured <code>--json</code> diagnostics, worktree-safe caches, and automatic <code>CI</code> detection.
    link: /docs/ci-and-agents
    linkText: CI/CD & Agents
---

## Quick Install

Install the standalone `nik` CLI strictly into your user directory (`~/.nikrun` on Linux and macOS, `%USERPROFILE%\.nikrun` on Windows):

::: code-group

```powershell [Windows]
irm https://nikrun.dev/install.ps1 | iex
```

```bash [Linux]
curl -fsSL https://nikrun.dev/install.sh | bash
```

```bash [macOS]
curl -fsSL https://nikrun.dev/install.sh | bash
```

:::

See [Installation](/docs/installation) for `insider` pre-release channels, version pinning, manual `.zip` archives, and uninstallation flags.

## Workflow in 60 Seconds

Provision a prebuilt Free Pascal SDK, scaffold a declarative `nik.yaml` manifest, and compile an optimized native binary into `bin/` while keeping `.ppu` and `.o` artifacts isolated in `.nik/cache/`:

::: code-group

```bash [Terminal]
# Install Free Pascal 3.2.4 (and/or 3.3.1 side by side)
nik sdk install 3.2.4

# Create project layout & manifest
nik init hello-nikrun
cd hello-nikrun

# Compile optimized release executable
nik build -p release
```

```yaml [nik.yaml]
schemaVersion: 1

program:
  name: hello-nikrun
  version: 0.1.0
  entry: src/main.pas
  output: bin/hello-nikrun

  toolchain:
    fpc: 3.2.4

  build:
    mode: objfpc
    longStrings: true
    unitPaths: [src]
```

:::

## Ecosystem & Supported Platforms

Both the `nik` CLI and prebuilt Free Pascal SDKs run natively across 64-bit desktop, server, and CI environments:

| Component | Repository | Description |
| :--- | :--- | :--- |
| **CLI (`nik`)** | [`nikrun/cli`](https://github.com/nikrun/cli) | Dependency-free native Object Pascal binary managing SDKs, scaffolding, builds, packages, and `nik lsp`. |
| **Free Pascal SDKs** | [`nikrun/sdk`](https://github.com/nikrun/sdk) | Automated portable SDK builds (`3.2.2` to nightly `3.3.1`) for `x86_64` and `aarch64` across Windows, Linux, and macOS. |
| **Nikrun for VS Code** | [`nikrun/vscode`](https://github.com/nikrun/vscode) | Official extension (`nikrun.vscode`) with live `nik lsp` diagnostics, RTL navigation, status-bar switchers, and `nik.yaml` validation. |

Continue in the documentation: [Overview](/docs/) · [Quickstart](/docs/quickstart) · [CLI Reference](/docs/reference/cli) · [Manifest & Lockfile Reference](/docs/reference/manifest)
