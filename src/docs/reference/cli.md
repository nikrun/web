# CLI

Complete command and option reference for the `nik` executable.

```text
nik [GLOBAL OPTIONS] <COMMAND> [ARGS]
```

## Global Options

Accepted before or after any `<COMMAND>`:

| Option | Description |
| :--- | :--- |
| `--nikrun-home <DIR>` | Override the Nikrun root directory (defaults to `~/.nikrun` or `$NIKRUN_HOME`). |
| `--no-color` | Disable ANSI colored output (also enabled automatically when `NO_COLOR` is non-empty or `stdout` is not a TTY). |
| `-V`, `--version` | Print `nik` version, host target triplet, and compiler build info. |
| `-h`, `--help` | Display global or command-specific help. |

## `init`

Scaffold a new Free Pascal project (`nik.yaml`, `.gitignore`, and starter source file).

```text
nik init [<DIR>] [OPTIONS]
```

| Argument / Option | Default | Description |
| :--- | :--- | :--- |
| `[<DIR>]` | `.` | Target directory (created if it does not exist). |
| `--program` | *(default)* | Initialize an executable application (`program`). |
| `--lib`, `--library` | — | Initialize a native shared library (`library`). |
| `--pkg`, `--package` | — | Initialize a reusable source unit collection (`package`). |
| `--name <NAME>` | Directory name | Project or package name written to `nik.yaml`. |
| `--fpc <VERSION>` | Highest installed SDK (or `3.2.4`) | Exact Free Pascal version written to `toolchain.fpc`. |
| `--template <FILE>` | `~/.nikrun/template.yaml` (if present) | Blueprint YAML file applied during scaffolding. |
| `-f`, `--force` | `false` | Overwrite an existing `nik.yaml` file. |
| `--json` | `false` | Emit structured JSON initialization summary. |

## `build`

Compile a `program` or `library` project using `nik.yaml`.

```text
nik build [OPTIONS]
```

| Option | Default | Description |
| :--- | :--- | :--- |
| `-p`, `--profile <NAME>` | `debug` | Build using the named profile from `nik.yaml`. |
| `-m`, `--manifest <PATH>` | `./nik.yaml` | Path to `nik.yaml` (`nik.yml`) or project directory. |
| `--clean` | `false` | Delete the active profile's build cache (`.nik/cache/...`) and pass `-B` to `ppc*`. |
| `--locked` | `false` | Require `nik.lock` to exist and match `nik.yaml` without modifying it. |
| `--offline` | `false` | Resolve dependencies strictly from `~/.nikrun/cache/pkg` without network access. |
| `-v`, `--verbose` | `false` | Print full `ppc*` command line and include compiler notes and hints. |
| `--json` | `false` | Emit structured JSON build report and parsed compiler diagnostics. |

## `pkg`

Fetch, update, list, and inspect project dependencies declared in `nik.yaml`.

### `fetch`

Download and verify all dependencies declared across `nik.yaml` (`dependencies`, `test.dependencies`, `targets`, `profiles`) and sync `nik.lock`.

| Option | Default | Description |
| :--- | :--- | :--- |
| `-m`, `--manifest <PATH>` | `./nik.yaml` | Path to `nik.yaml` or project directory. |
| `--locked` | `false` | Require `nik.lock` to be in sync without modifying it. |
| `--offline` | `false` | Verify strictly against `~/.nikrun/cache/pkg` without network access. |
| `--json` | `false` | Output machine-readable JSON. |

### `update`

Upgrade locked SemVer versions in `nik.lock` to the newest compatible Git tags within `nik.yaml` constraints.

| Argument / Option | Default | Description |
| :--- | :--- | :--- |
| `[<NAME>]` | *(all packages)* | Specific dependency alias from `nik.yaml` to upgrade. |
| `-m`, `--manifest <PATH>` | `./nik.yaml` | Path to `nik.yaml` or project directory. |
| `--json` | `false` | Output machine-readable JSON. |

### `list`

List resolved direct and transitive dependencies, resolved versions/commits, and cache paths.

| Option | Default | Description |
| :--- | :--- | :--- |
| `-p`, `--profile <NAME>` | `debug` | Resolve dependency graph for the named profile. |
| `--test` | `false` | Include `test.dependencies` in resolution. |
| `--offline` | `false` | Resolve strictly from `~/.nikrun/cache/pkg` without network access. |
| `-m`, `--manifest <PATH>` | `./nik.yaml` | Path to `nik.yaml` or project directory. |
| `--json` | `false` | Output machine-readable JSON. |

### `info`

Query a remote Git repository URL for SemVer tags, `HEAD` commit hash, and a ready-to-paste `nik.yaml` dependency entry.

```text
nik pkg info <URL> [--json]
```

## `sdk`

Discover, install, update, inspect, and remove portable Free Pascal SDKs under `~/.nikrun/sdks/`.

### `list`

| Option | Default | Description |
| :--- | :--- | :--- |
| `-r`, `--remote` | `false` | Query remote `index.json` instead of locally installed SDKs. |
| `--version <VER>` | *(all)* | Filter by FPC version (e.g. `3.2.4`, `3.3.1`). |
| `--os <OS>` | *(all)* | Filter by target OS (`win64`, `linux`, `darwin`). |
| `--arch <CPU>` | *(all)* | Filter by target CPU (`x86_64`, `aarch64`). |
| `--index-url <URL>` | Official `nikrun/sdk` index | Override remote `index.json` URL or local file path. |
| `--json` | `false` | Output machine-readable JSON. |

### `install`

```text
nik sdk install <VERSION|PATH> [OPTIONS]
```

| Argument / Option | Default | Description |
| :--- | :--- | :--- |
| `<VERSION\|PATH>` | *(required)* | Exact FPC version (e.g. `3.2.4`, `3.3.1`) or path to a local SDK `.zip` / directory. |
| `-f`, `--force` | `false` | Reinstall even if the matching SDK is already installed. |
| `--skip-verify` | `false` | Skip SHA-256 checksum verification. |
| `--os <OS>` | Host OS | Override target OS (`win64`, `linux`, `darwin`). |
| `--arch <CPU>` | Host CPU | Override target CPU (`x86_64`, `aarch64`). |
| `--index-url <URL>` | Official `nikrun/sdk` index | Override remote `index.json` URL or local file path. |

### `update`

```text
nik sdk update [<VERSION>] [OPTIONS]
```

| Argument / Option | Default | Description |
| :--- | :--- | :--- |
| `[<VERSION>]` | *(all installed)* | Specific installed FPC version to update. |
| `--skip-verify` | `false` | Skip SHA-256 checksum verification. |
| `--os <OS>` | *(all)* | Filter target OS (`win64`, `linux`, `darwin`). |
| `--arch <CPU>` | *(all)* | Filter target CPU (`x86_64`, `aarch64`). |
| `--index-url <URL>` | Official `nikrun/sdk` index | Override remote `index.json` URL or local file path. |
| `--json` | `false` | Output machine-readable JSON. |

### `info` & `uninstall`

```text
nik sdk info <VERSION> [--os <OS>] [--arch <CPU>] [--json]
nik sdk uninstall <VERSION> [--os <OS>] [--arch <CPU>]
```

## `lsp`

Start the built-in Free Pascal Language Server (LSP 3.17).

```text
nik lsp [OPTIONS]
```

| Option | Default | Description |
| :--- | :--- | :--- |
| `--stdio` | `true` | Communicate over standard input/output (`Content-Length` framed JSON-RPC 2.0). |
| `--socket <PORT>` | — | Listen for a single LSP client connection on `127.0.0.1:<PORT>`. |
| `-p`, `--profile <NAME>` | `debug` | Resolve `nik.yaml` using the named profile. |
| `-m`, `--manifest <PATH>` | `./nik.yaml` | Explicit path to `nik.yaml` or project directory. |
| `--log-file <PATH>` | — | Append JSON-RPC and server diagnostic logs to `<PATH>`. |

## Exit Codes

| Exit Code | Meaning |
| :---: | :--- |
| `0` | Command succeeded. |
| `1` | Command, validation, or compilation failed. |
| `> 1` | Underlying compiler process exit status or signal termination (`128 + signal`). |
