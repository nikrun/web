# VS Code & Language Server

Nikrun ships a built-in Language Server (**`nik lsp`**, implementing LSP 3.17) inside the `nik` binary and an official Visual Studio Code extension. Because `nik lsp` reads `nik.yaml` and `sdk-manifest.json` directly, code intelligence works out of the box with zero path setup.

## Extension

Install **Nikrun — Free Pascal & Object Pascal** ([`nikrun/vscode`](https://github.com/nikrun/vscode)) from the VS Code Marketplace (requires `nik` installed in `~/.nikrun/bin` or on `PATH`).

The extension activates automatically whenever a workspace contains `nik.yaml` / `nik.yml` or an Object Pascal file (`.pas`, `.pp`, `.lpr`, `.dpr`, `.inc`) is opened.

### Features

- **Live Compiler Diagnostics:** Runs `ppc* -Cn` asynchronously in the background (with 250 ms debouncing) against unsaved editor buffers using an isolated overlay directory (`.nik/cache/<sdkId>-<profile>-lsp/overlay`), reporting exact errors, warnings, notes, and hints as you type.
- **Navigation & Symbols:** `Go to Definition` across project units, cached packages, and bundled SDK `source/rtl` and `source/packages` files, plus Outline/Breadcrumbs (`Document Symbols`), `Workspace Symbols`, PasDoc `Hover` documentation, `Signature Help`, and `Completion`.
- **Status-Bar Switchers:** Click the FPC version in the status bar to switch `toolchain.fpc` in `nik.yaml` or install/update prebuilt SDKs; click the profile item to toggle `debug`, `release`, or custom profiles (reloading `nik lsp` automatically).
- **`nik.yaml` Validation:** Bundled JSON Schema validation and autocompletion for `nik.yaml` and `nik.yml` (integrates automatically with the Red Hat YAML extension).
- **Duplicate-Free Build Tasks:** Built-in `nik: build` and `nik: build --clean` tasks (`Ctrl+Shift+B`). When `nik lsp` is enabled, diagnostic ownership stays with `nik lsp` so the *Problems* panel never shows duplicate markers.
- **Modern Object Pascal Grammar:** Syntax highlighting supporting `&`-escaped identifiers, dotted unit/member names, structured compiler directives, and attributes.

### Commands

Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`):

| Command | Action |
| :--- | :--- |
| `Nikrun: Initialize Project (nik init)` | Scaffolds `nik.yaml` (`program`, `library`, or `package`) in the open workspace folder. |
| `Nikrun: Select Project FPC Version or Install SDK` | Switches `toolchain.fpc` in `nik.yaml` or installs/updates an SDK in `~/.nikrun`. |
| `Nikrun: Update Installed SDKs (nik sdk update)` | Updates locally installed SDKs to the newest remote builds. |
| `Nikrun: Select Active Build Profile` | Switches the active `nik.yaml` profile for both `nik lsp` and `nik build`. |
| `Nikrun: Build Project (nik build)` | Compiles the project using the active profile. |
| `Nikrun: Clean & Rebuild Project (nik build --clean)` | Cleans the profile's build cache and forces a full rebuild. |
| `Nikrun: Restart Language Server (nik lsp)` | Restarts the `nik lsp` background process. |
| `Nikrun: Show Language Server Output` | Opens the Nikrun Language Server output channel. |

### Settings

| Setting | Default | Description |
| :--- | :--- | :--- |
| `nikrun.cliPath` | `""` | Explicit path to `nik` (`nik.exe`). When empty, resolves `~/.nikrun/bin/nik` (or `$NIKRUN_HOME/bin/nik`) and `PATH` automatically. |
| `nikrun.nikrunHome` | `""` | Overrides `--nikrun-home` / `NIKRUN_HOME` (defaults to `~/.nikrun`). |
| `nikrun.profile` | `"debug"` | Active `nik.yaml` profile passed to `nik lsp` and `nik build`. |
| `nikrun.lsp.enabled` | `true` | Enables or disables the `nik lsp` Language Server. |
| `nikrun.lsp.logFile` | `""` | File path passed to `nik lsp --log-file` for JSON-RPC debugging. |
| `nikrun.trace.server` | `"off"` | Traces JSON-RPC traffic in VS Code (`"off"`, `"messages"`, `"verbose"`). |

## Other Editors

Any editor with an LSP client (Neovim, Helix, Zed, Sublime Text, Emacs) can launch `nik lsp` directly over `stdio` or TCP:

```bash
# Standard input/output (default)
nik lsp --stdio --profile debug

# TCP socket on 127.0.0.1:<port> with protocol trace logging
nik lsp --socket 10090 --log-file .nik/lsp.log
```

Set the workspace root to the directory containing `nik.yaml`.
