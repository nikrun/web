# SDK

Nikrun distributes prebuilt, portable Free Pascal toolchains (`nikrun/sdk`) that install side by side inside `~/.nikrun/sdks/`. There is no global "active" SDK on your machine—each project specifies its required compiler version in `nik.yaml` under `toolchain.fpc`.

## Commands

```bash
nik sdk list                 # List locally installed SDKs
nik sdk list --remote        # List all prebuilt SDKs available for download
nik sdk install 3.2.4        # Download, verify SHA-256, and configure FPC 3.2.4
nik sdk install 3.3.1        # Install nightly trunk alongside 3.2.4
nik sdk update               # Update all installed SDKs to the newest remote commits
nik sdk update 3.3.1         # Update a single SDK version
nik sdk info 3.2.4           # Inspect verified compiler, unit, and source paths
nik sdk uninstall 3.2.2      # Remove an installed SDK
```

You can also install a downloaded `.zip` archive or extracted SDK folder offline:

```bash
nik sdk install ./nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-win64.zip
```

## Versions & Targets

[`nikrun/sdk`](https://github.com/nikrun/sdk) builds portable SDK archives automatically from upstream Free Pascal release, maintenance, and development branches whenever new commits land.

For the current list of published Free Pascal versions, upstream Git commits, and OS/CPU targets:

- View the automated release matrix on [**`nikrun/sdk` Releases (`latest`)**](https://github.com/nikrun/sdk/releases/latest).
- Or query the live SDK Index directly from your terminal with `nik sdk list --remote`.

> [!NOTE]
> On Windows ARM64 (`aarch64-win64`), trunk builds run natively as ARM64 (`ppca64.exe`). For earlier `3.2.x` versions where upstream Free Pascal has no native `aarch64-win64` target, `nik` automatically resolves and runs the compatible `x86_64-win64` SDK.

## Directory Layout & `sdk-manifest.json`

Every extracted SDK under `~/.nikrun/sdks/<sdkId>/` shares an identical layout across Windows, Linux, and macOS:

```text
~/.nikrun/sdks/nikrun-fpc-sdk-<version>-<commitShortSha>-<cpu>-<os>/
├── sdk-manifest.json      # SDK Manifest (version, Git commit, target, relative paths)
├── bin/<cpu>-<os>/        # ppcx64/ppca64, fpc, fpcmkcfg, binutils, and generated fpc.cfg
├── units/<cpu>-<os>/      # Precompiled .ppu & .o units (rtl, fcl-*, rtl-generics, ...)
├── source/
│   ├── rtl/               # Clean RTL sources (.pas, .pp, .inc) for nik lsp navigation
│   └── packages/          # Clean standard package sources for nik lsp navigation
└── licenses/              # Upstream Free Pascal & binutils license notices
```

Unlike the developer-authored **Project Manifest** (`nik.yaml`), the **SDK Manifest** (`sdk-manifest.json`) is generated during SDK packaging and read by `nik` to verify toolchain integrity and locate binaries without searching the system `PATH`.

## Isolated `fpc.cfg` & Direct `ppc*` Invocation

1. **Per-SDK `fpc.cfg`:** During `nik sdk install`, `nik` generates a self-contained `fpc.cfg` inside `bin/<cpu>-<os>/` (automatically resolving Xcode SDK sysroots via `xcrun` on macOS and multiarch library paths on Linux).
2. **Direct compiler execution:** In Free Pascal, `fpc` is only a thin wrapper executable that looks up a CPU backend (`ppcx64` or `ppca64`) on `PATH`. `nik build` and `nik lsp` bypass `fpc` and invoke `paths.ppcBinary` directly with `-n @<sdk>/bin/<cpu>-<os>/fpc.cfg`. Global `/etc/fpc.cfg` or `~/.fpc.cfg` files are always ignored (`-n`).
