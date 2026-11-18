# Installation

Nikrun installs strictly into your user directory (`~/.nikrun` on Linux/macOS, `%USERPROFILE%\.nikrun` on Windows). It requires no administrator or `root` privileges and never modifies system-wide Free Pascal configurations.

Releases are published in two channels—available both through the terminal installer and as downloadable archives on [GitHub Releases](https://github.com/nikrun/cli/releases):

- **`stable`** *(default)* — Regular versioned releases recommended for everyday use.
- **`insider`** — Pre-release builds published from the latest verified commits.

## Via Script

Run the one-line installer in your terminal to set up the latest `stable` release automatically:

::: code-group

```powershell [Windows (PowerShell)]
irm https://nikrun.dev/install.ps1 | iex
```

```bash [Linux / macOS]
curl -fsSL https://nikrun.dev/install.sh | bash
```

:::

The script performs four steps:

1. Detects your native OS and CPU architecture (including Windows ARM64 and Apple Silicon under Rosetta).
2. Downloads the matching `nik` archive from [`nikrun/cli`](https://github.com/nikrun/cli/releases) and verifies its SHA-256 checksum.
3. Extracts `nik` (`nik.exe` on Windows) to `~/.nikrun/bin` and places a local uninstall script in `~/.nikrun/`.
4. Adds `~/.nikrun/bin` to your user `PATH` (and registers `Nikrun CLI` under Windows *Installed Apps* in `HKCU`).

Open a new terminal session and verify the setup:

```bash
nik --version
```

Re-running the script at any time updates an existing `nik` installation in place without affecting installed SDKs or caches.

### Options

Use environment variables or script flags to select the `insider` channel, install a specific version, or customize setup behavior:

| Option / Variable | Platform | Description |
| :--- | :--- | :--- |
| `NIKRUN_CHANNEL` / `-c`, `--channel` | All | Release channel: `stable` (default) or `insider`. |
| `NIKRUN_VERSION` / `-v`, `--version` | All | Exact version or Git tag to install (e.g. `0.1.0` or `v0.1.0`). |
| `NIKRUN_HOME` | All | Custom installation root (defaults to `~/.nikrun` or `%USERPROFILE%\.nikrun`). |
| `--no-modify-path` | Linux / macOS | Do not append `~/.nikrun/bin` to `.bashrc`, `.zshrc`, or `config.fish`. |
| `GITHUB_TOKEN` / `GH_TOKEN` | All | Optional GitHub token used to avoid API rate limits in CI runners. |

::: code-group

```powershell [Windows (PowerShell)]
# Install from the insider channel
$env:NIKRUN_CHANNEL = 'insider'; irm https://nikrun.dev/install.ps1 | iex

# Install a specific version
$env:NIKRUN_VERSION = '0.1.0'; irm https://nikrun.dev/install.ps1 | iex
```

```bash [Linux / macOS]
# Install from the insider channel
curl -fsSL https://nikrun.dev/install.sh | bash -s -- --channel insider

# Install a specific version without modifying shell profiles
curl -fsSL https://nikrun.dev/install.sh | bash -s -- --version 0.1.0 --no-modify-path
```

:::

## Manual Archive

If you prefer to download and configure the binary yourself without running a script:

1. Choose a `stable` release or `insider` pre-release on [`github.com/nikrun/cli/releases`](https://github.com/nikrun/cli/releases) and download `nik-<version>-<cpu>-<os>.zip` along with `manifest.json`.
2. Verify the archive's SHA-256 checksum against `manifest.json`.
3. Extract `nik` (`nik.exe` on Windows) into `~/.nikrun/bin` (or `%USERPROFILE%\.nikrun\bin`) and add that directory to your user `PATH`.

## Uninstalling

The uninstaller stops running `nik` processes (such as `nik lsp`), removes `~/.nikrun/bin/nik`, and cleans up your user `PATH`.

::: code-group

```powershell [Windows (PowerShell)]
# Interactive (asks whether to keep or delete installed SDKs and caches)
irm https://nikrun.dev/uninstall.ps1 | iex

# Non-interactive: remove everything including ~/.nikrun/sdks and ~/.nikrun/cache
& "$env:USERPROFILE\.nikrun\uninstall.ps1" -Purge -NonInteractive
```

```bash [Linux / macOS]
# Interactive (asks whether to keep or delete installed SDKs and caches)
curl -fsSL https://nikrun.dev/uninstall.sh | bash

# Non-interactive: remove everything including ~/.nikrun/sdks and ~/.nikrun/cache
~/.nikrun/uninstall.sh --purge --non-interactive
```

:::

| Flag (PowerShell / Bash) | Behavior |
| :--- | :--- |
| `-Purge` / `--purge` | Deletes the entire `~/.nikrun` directory, including all installed SDKs and the package cache. |
| `-KeepData` / `--keep-data` | Removes the `nik` binary and `PATH` entry, keeping `~/.nikrun/sdks` and `~/.nikrun/cache`. |
| `-NonInteractive` / `--non-interactive` | Suppresses interactive confirmation prompts (defaults to keeping data unless `--purge` is passed). |
