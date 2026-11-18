# Overview

**Nikrun** is a user-scope toolchain for **Free Pascal & Object Pascal**. It combines a dependency-free native CLI (`nik`), prebuilt portable Free Pascal SDKs (`nik sdk`), a declarative project manifest (`nik.yaml`), decentralized package management (`nik pkg`), a built-in Language Server (`nik lsp`), and an official VS Code extension.

## Ecosystem Components

| Component | Repository | Purpose |
| :--- | :--- | :--- |
| **CLI** | [`nikrun/cli`](https://github.com/nikrun/cli) | Standalone native `nik` binary managing SDKs, project scaffolding, builds, packages, and LSP. |
| **SDKs** | [`nikrun/sdk`](https://github.com/nikrun/sdk) | Prebuilt, SHA-256-verified Free Pascal archives (`3.2.2` to nightly `3.3.1`) with bundled RTL and package sources. |
| **VS Code Extension** | [`nikrun/vscode`](https://github.com/nikrun/vscode) | Zero-config IDE integration with status-bar SDK/profile switchers, build tasks, and `nik.yaml` validation. |

## Core Terminology

Nikrun uses a fixed set of terms across the CLI, VS Code extension, and documentation:

| Term | File / Location | Meaning |
| :--- | :--- | :--- |
| **SDK** | `~/.nikrun/sdks/<sdkId>/` | A self-contained Free Pascal toolchain archive (`ppc*` compiler, platform binutils, `.ppu` units, and `source/`). |
| **SDK Manifest** | `sdk-manifest.json` | Machine-readable metadata inside each installed SDK (FPC version, Git commit, target triplet, and binary paths). |
| **SDK Index** | `index.json` | Remote catalog published by `nikrun/sdk` listing available SDK archives and SHA-256 checksums. |
| **Project Manifest** | `nik.yaml` | Developer-maintained file in the project root declaring the project type, compiler version, build settings, dependencies, and profiles. |
| **Project Type** | `program` \| `library` \| `package` | Top-level key in `nik.yaml` defining whether the project builds an executable, a shared library, or a source unit package. |
| **Lockfile** | `nik.lock` | Auto-generated file locking exact dependency versions, Git commits, and SHA-256 hashes. |
| **Profile** | `profiles.<name>` / `-p <name>` | Named build configuration in `nik.yaml` (such as `debug` or `release`). |
| **Target** | `<cpu>-<os>` | Target CPU and operating system triplet (for example `x86_64-win64` or `aarch64-darwin`). |
| **Build Cache** | `.nik/cache/` | Project-local directory storing compiled `.ppu` and `.o` files per SDK and profile. |
| **Package Cache** | `~/.nikrun/cache/pkg/` | Read-only user-scope directory storing downloaded package sources. |

## Supported Platforms

Both the `nik` CLI and prebuilt Free Pascal SDKs run natively on 64-bit operating systems:

| Operating System | `x86_64` | `aarch64` (ARM64) | Target Triplets |
| :--- | :---: | :---: | :--- |
| **Windows** | Yes | Yes | `x86_64-win64`, `aarch64-win64` |
| **Linux** | Yes | Yes | `x86_64-linux`, `aarch64-linux` |
| **macOS** | Yes | Yes (Apple Silicon) | `x86_64-darwin`, `aarch64-darwin` |

## Comparison

Nikrun builds directly on the upstream Free Pascal compiler while targeting a different workflow than existing setup options. The official `freepascal.org` installers provide traditional system-wide installations, and `fpcupdeluxe` excels at compiling custom Free Pascal and Lazarus IDE setups locally from source. Nikrun is designed for developers and teams who want an instant, isolated CLI and VS Code workflow with zero system setup:

| Aspect | Official `freepascal.org` Installers | `fpcupdeluxe` | **Nikrun** |
| :--- | :--- | :--- | :--- |
| **System impact** | Global OS installers, admin/root rights, global `/etc/fpc.cfg` and `PATH` | Compiles FPC and Lazarus locally from source | User scope only (`~/.nikrun`), no admin/root rights, prebuilt `.zip` SDKs |
| **Parallel versions** | Static releases collide in global `PATH` / `fpc.cfg` | Supported via local source builds | Side-by-side `3.2.2`, `3.2.4`, `3.2.5`, and nightly `3.3.1` in seconds |
| **RTL sources** | Often separate download or OS-specific path | Installed locally | Bundled in every SDK (`source/rtl`, `source/packages`) |
| **Build & packages** | Compiler only (`fpc` CLI flags / Makefiles) | Focused on Lazarus IDE setup | Declarative `nik.yaml`, `nik pkg` & `nik.lock`, isolated `.nik/cache/` |
| **Editor & CI** | External setup required | Lazarus IDE | Built-in `nik lsp`, official VS Code extension, and `--json` CLI output |

## Next Steps

- [Installation](./installation) — Install the `nik` CLI on Windows, Linux, or macOS.
- [Quickstart](./quickstart) — Install a Free Pascal SDK and compile your first project in 60 seconds.
