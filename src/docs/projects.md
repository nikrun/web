# Project

Every Nikrun project is configured by a single **Project Manifest** named `nik.yaml` (or `nik.yml`) in the project root. `nik` never modifies `nik.yaml` behind your back—it is strictly owned by you and committed to version control.

## Types

A `nik.yaml` file declares `schemaVersion: 1` and **exactly one** top-level project type:

| Project Type | Scaffold Command | Entry Source | Compiled Output |
| :--- | :--- | :--- | :--- |
| **`program`** | `nik init <dir>` *(default)* | **Required** (`program MyApp;`) | Native executable (`bin/<name>` or `bin\<name>.exe`) |
| **`library`** | `nik init <dir> --lib` | **Required** (`library MyLib;`) | Native shared library (`.dll`, `lib<name>.so`, or `lib<name>.dylib`; `-Cg` PIC enabled automatically on Unix) |
| **`package`** | `nik init <dir> --pkg` | **Disallowed** | None — source units compiled directly into consuming `program` or `library` projects |

```bash
nik init my-app                  # Application (program)
nik init my-plugin --lib         # Shared library (library)
nik init my-utils --pkg          # Reusable unit collection (package)
```

## Example `nik.yaml`

```yaml
schemaVersion: 1

program:
  name: my-app
  version: 0.1.0
  entry: src/main.pas
  output: bin/my-app

  toolchain:
    fpc: 3.2.4

  build:
    mode: objfpc
    longStrings: true
    cOperators: true
    modeSwitches: [advancedRecords, typeHelpers]
    unitPaths: [src]

  dependencies:
    my-utils: ../my-utils

  targets:
    windows:
      build:
        unitPaths: [src/win]
    unix:
      build:
        unitPaths: [src/unix]
        linkLibraries: [pthread]

  profiles:
    debug:
      build:
        debugInfo: dwarf3
    release:
      build:
        optimization: 3
        warnings:
          asErrors: true
```

## Profiles (`debug`, `release` & Custom)

Profiles customize compiler or toolchain settings for different workflows (selected via `nik build -p <profile>`, defaulting to `debug`).

`debug` and `release` provide built-in baseline defaults even if omitted from `nik.yaml`:

| Setting | Built-in `debug` Default | Built-in `release` Default | Custom Profile Baseline |
| :--- | :--- | :--- | :--- |
| `defines` | `[DEBUG]` | `[RELEASE]` | `[]` |
| `debugInfo` | `dwarf2` (`-gl -gw2`) | `none` (`-g-`) | `none` |
| `assertions` | `true` (`-Sa`) | `false` (`-Sa-`) | *(compiler default)* |
| `checks` | `[range, overflow, io]` | *(disabled)* | *(disabled)* |
| `optimization` | *(compiler default)* | `2` (`-O2`) | *(compiler default)* |
| `smartLink` | `false` | `true` (`-CX -XX`) | `false` |
| `stripSymbols` | `false` | `true` (`-Xs`) | `false` |

You can also switch `toolchain.fpc` inside a profile—for example, defining a `trunk` profile with `toolchain: { fpc: "3.3.1" }` to test compatibility against Free Pascal trunk.

## Platform Targets (`targets:`)

The `targets:` section applies platform-specific settings automatically based on the target SDK's CPU and OS. Supported target keys:

- **OS family:** `unix` (matches both `linux` and `darwin`)
- **OS:** `windows` (or `win64`), `linux`, `macos` (or `darwin`)
- **CPU:** `x86_64`, `aarch64`
- **Exact triplet:** `x86_64-win64`, `aarch64-win64`, `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`

## Precedence Order & List Merging

When resolving `nik.yaml`, settings are layered in exact order from lowest to highest priority:

1. **Built-in profile defaults** (`debug` or `release`)
2. **Base project section** (`program`, `library`, or `package`)
3. **Matching `targets` sections** in order of specificity:
   `unix` → OS (`windows`/`linux`/`darwin`) → CPU (`x86_64`/`aarch64`) → exact `<cpu>-<os>` triplet
4. **Active `profiles.<name>` section**

**List merging:** List fields (`unitPaths`, `includePaths`, `libraryPaths`, `objectPaths`, `resourcePaths`, `modeSwitches`, `defines`, `undefines`, `warnings.suppress`, `linkLibraries`, `linkerArgs`, `fpcArgs`) **append** items across layers. Place `"$reset"` as the first item in a list to clear inherited values before adding new ones:

```yaml
profiles:
  release:
    build:
      defines: ["$reset", RELEASE, NDEBUG]
```

## Custom Template (`~/.nikrun/template.yaml`)

To pre-populate your preferred license, author list, dialect switches, or profiles whenever you run `nik init`, create `~/.nikrun/template.yaml` (or pass `nik init --template <file>`):

```yaml
schemaVersion: 1

template:
  license: MIT
  authors: ["Jane Doe"]
  toolchain:
    fpc: 3.2.4
  build:
    mode: objfpc
    cOperators: true
    modeSwitches: [advancedRecords, typeHelpers]
```

`nik init` copies these values into the new project's `nik.yaml` once at creation time. Existing projects never read `~/.nikrun/template.yaml`, keeping builds reproducible across machines.

For every supported key and compiler flag mapping, see the [`nik.yaml` Reference](./reference/manifest).
