# FAQ & Licensing

## Licensing

### Can I build commercial or proprietary software?

**No.** Compiling, analyzing, or scaffolding your code with `nik`, `nik lsp`, the Nikrun VS Code extension, and Nikrun's portable Free Pascal SDKs imposes **zero Nikrun licensing obligations** on your source code or compiled binaries. You can distribute your software under any open-source, commercial, or closed-source proprietary license.

### Component Overview

| Component | License | Impact on Your Project |
| :--- | :--- | :--- |
| **`nik` CLI & VS Code Extension** | `GPL-3.0-or-later` | Standalone developer tools invoked externally; their license does not apply to projects you build. |
| **Free Pascal Compiler (`ppc*`)** | `GPL-2.0-or-later` | Compiler output is unrestricted; only modifications to the compiler itself fall under GPL. |
| **Free Pascal RTL & Standard Packages** | Modified LGPL (`COPYING.FPC`) | Includes an explicit **static-linking exception** permitting commercial and closed-source executables and libraries. |
| **Bundled Platform Binutils** | `GPL-3.0` / `Apache-2.0 WITH LLVM-exception` | Build-time assemblers/linkers (`ld`, `windres`, `clang`/`llvm-ar`); no license impact on linked binaries. |

---

## Troubleshooting

### `nik` is not recognized after installation

Open a **new** terminal window so your updated user `PATH` (`~/.nikrun/bin` or `%USERPROFILE%\.nikrun\bin`) takes effect. On Linux/macOS with custom shell setups, verify `~/.nikrun/bin` is in `echo $PATH`.

### Project requires FPC `<version>`, which is not installed

Nikrun never falls back silently to a different Free Pascal version than the one specified in `nik.yaml`. Install the exact version requested by the project:

```bash
nik sdk install 3.2.4
```

### Linker errors on Linux (`cannot find -lc` or `crti.o`)

Free Pascal links native binaries against the host C library startup files on Linux when calling C libraries (such as `pthread` or `dl`). Ensure standard system binutils and C development headers are installed (`build-essential` on Debian/Ubuntu, `gcc` / `glibc-devel` on Fedora/RHEL, `base-devel` on Arch).

### Linker or SDK sysroot errors after a macOS / Xcode update

Each Nikrun SDK records the macOS SDK sysroot (`-XR`) inside its generated `fpc.cfg` at installation time. After upgrading Xcode or Command Line Tools (`xcode-select --install`), regenerate the SDK configuration with:

```bash
nik sdk install <version> --force
```

### `nik build --locked` fails in CI

`--locked` fails whenever `nik.lock` is missing or out of sync with `nik.yaml`. Run `nik pkg fetch` locally, verify the diff in `nik.lock`, and commit `nik.lock` to your repository.
