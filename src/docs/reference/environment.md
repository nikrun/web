# Paths & Environment

Complete reference of filesystem locations and environment variables used by Nikrun.

## Variables

### CLI

| Variable | CLI Equivalent | Default | Description |
| :--- | :--- | :--- | :--- |
| `NIKRUN_HOME` | `--nikrun-home <DIR>` | `~/.nikrun` (`%USERPROFILE%\.nikrun`) | Root directory for `bin/`, `sdks/`, `cache/`, and `template.yaml`. |
| `NIKRUN_SDK_INDEX_URL` | `--index-url <URL>` | `https://github.com/nikrun/sdk/releases/download/latest/index.json` | Remote URL or local file path for the SDK Index (`index.json`). |
| `NO_COLOR` | `--no-color` | *(unset)* | Disables ANSI colors and terminal styling when set to any non-empty value. |
| `CI` | *(auto-detected)* | *(unset)* | Switches `nik` to non-interactive headless output when set. |

### Installer Scripts (`install.ps1` / `install.sh`)

| Variable | Default | Description |
| :--- | :--- | :--- |
| `NIKRUN_CHANNEL` | `stable` | Release channel to install (`stable` or `insider`). |
| `NIKRUN_VERSION` | *(latest)* | Specific `nik` CLI version or tag to install. |
| `GITHUB_TOKEN` / `GH_TOKEN` | *(unset)* | Optional GitHub API bearer token to avoid anonymous rate limits in CI. |

## User Directory (`NIKRUN_HOME`)

Default root:
- **Linux / macOS:** `~/.nikrun`
- **Windows:** `%USERPROFILE%\.nikrun` (e.g. `C:\Users\<Name>\.nikrun`)

```text
~/.nikrun/
├── bin/
│   └── nik(.exe)                    # Standalone Nikrun CLI executable
├── sdks/
│   └── nikrun-fpc-sdk-<ver>-<sha>-<cpu>-<os>/
│       ├── sdk-manifest.json        # SDK Manifest
│       ├── bin/<cpu>-<os>/          # ppc*, fpc, binutils & isolated fpc.cfg
│       ├── units/<cpu>-<os>/        # Precompiled .ppu & .o units
│       └── source/                  # Clean rtl/ and packages/ Pascal sources
├── cache/
│   └── pkg/                         # Immutable Package Cache (downloaded Git/archive deps)
├── template.yaml                    # Optional user blueprint applied by 'nik init'
└── uninstall.sh / uninstall.ps1     # Local uninstaller script
```

## Project Directory

```text
<project>/
├── nik.yaml                         # Project Manifest (committed to Git)
├── nik.lock                         # Dependency Lockfile (committed to Git when using remote/archive deps)
├── src/                             # Project Pascal sources (.pas, .pp, .inc)
├── bin/                             # Default compiled output binaries (gitignored)
└── .nik/                            # Project-local working directory (gitignored)
    └── cache/
        ├── <sdkId>-<profile>/       # Build Cache (.ppu, .o, link.res)
        └── <sdkId>-<profile>-lsp/   # nik lsp check cache & unsaved buffer overlay
```
