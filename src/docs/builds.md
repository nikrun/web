# Building

`nik build` resolves `nik.yaml`, verifies the required Free Pascal SDK, fetches any missing dependencies, and compiles `program` or `library` projects directly via the SDK's `ppc*` compiler backend.

> [!NOTE]
> Source-only `package` projects do not define a binary target. Their units are compiled when building a consuming `program` or `library` project (and checked continuously by `nik lsp`).

## Basic Usage

```bash
nik build                        # Build with the default 'debug' profile
nik build -p release             # Build with the 'release' profile
nik build --clean                # Delete the active profile's build cache and force rebuild (-B)
nik build --verbose              # Print the exact ppc* command line and all notes/hints
nik build -m path/to/nik.yaml    # Build a project in another directory
```

## Output Binaries

`nik` automatically appends the native platform extension (and `lib` prefix on Unix shared libraries) when `output` in `nik.yaml` omits a file extension:

| Project Type | output in nik.yaml | Windows (win64) | Linux (linux) | macOS (darwin) |
| :--- | :--- | :--- | :--- | :--- |
| **`program`** | `bin/my-app` *(default)* | `bin\my-app.exe` | `bin/my-app` | `bin/my-app` |
| **`library`** | `bin/my-plugin` *(default)* | `bin\my-plugin.dll` | `bin/libmy-plugin.so` | `bin/libmy-plugin.dylib` |

## Cache (`.nik/cache/`)

Free Pascal never scatters `.ppu`, `.o`, or `.or` files into your `src/` or `packages/` folders when invoked through `nik`.

All intermediate compilation artifacts are written to a project-local **Build Cache** directory scoped by the exact SDK identifier and profile name:

```text
<project>/
├── bin/
│   └── my-app(.exe)
└── .nik/
    └── cache/
        ├── nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-win64-debug/
        └── nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-win64-release/
```

Because the build cache is isolated per directory, SDK, and profile:

- Switching between `debug`, `release`, and `3.3.1` profiles never invalidates or corrupts previously compiled units.
- Separate Git worktrees never collide.
- Downloaded packages in `~/.nikrun/cache/pkg/` remain strictly read-only—their `.ppu` files are compiled into the consuming project's `.nik/cache/` directory.

Pass `--clean` to delete the active profile's build cache directory and pass `-B` to `ppc*` for a full rebuild.

## Locked & Offline Mode

| Flag | Behavior |
| :--- | :--- |
| *(default)* | Downloads missing packages into `~/.nikrun/cache/pkg/` and writes or updates `nik.lock` if needed. |
| `--locked` | Requires `nik.lock` to exist and match `nik.yaml` without modification. Fails immediately if `nik.lock` is missing or out of sync (recommended for CI). |
| `--offline` | Resolves all dependencies strictly from `~/.nikrun/cache/pkg/` without network access and never rewrites `nik.lock`. |
