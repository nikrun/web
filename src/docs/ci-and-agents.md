# CI/CD & AI Agents

`nik` is designed for both interactive terminals and automated environments such as CI pipelines and AI coding agents.

## Headless Behavior

When `stdout` is redirected, `CI` is set, or `NO_COLOR` is non-empty, `nik` automatically:

- Disables cursor-rewriting progress spinners and ANSI color escapes.
- Never blocks on interactive prompts.
- Isolates compiled units in `.nik/cache/<sdkId>-<profile>` so parallel Git worktrees or concurrent agent runs never collide.

## JSON Output (`--json`)

Every inspection and build command supports `--json`, emitting deterministic JSON to `stdout`:

- `nik build --json`
- `nik init --json`
- `nik sdk list --json`, `nik sdk info <ver> --json`, `nik sdk update --json`
- `nik pkg fetch --json`, `nik pkg update --json`, `nik pkg list --json`, `nik pkg info <url> --json`

### `nik build` Schema

`nik build --json` parses raw Free Pascal (`ppc* -vq`) output into structured compiler diagnostics with exact file paths, line numbers, columns, numeric FPC message codes, and severities (`fatal`, `error`, `warning`, `note`, `hint`):

```json
{
  "success": false,
  "exitCode": 1,
  "durationMs": 42,
  "project": {
    "kind": "program",
    "name": "my-app",
    "version": "0.1.0",
    "profile": "debug",
    "manifestPath": "/work/my-app/nik.yaml",
    "projectDir": "/work/my-app",
    "entryPath": "/work/my-app/src/main.pas"
  },
  "toolchain": {
    "sdkId": "nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-linux",
    "fpcVersion": "3.2.4",
    "targetTriplet": "x86_64-linux",
    "compilerBinary": "/home/runner/.nikrun/sdks/nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-linux/bin/x86_64-linux/ppcx64",
    "fpcCfg": "/home/runner/.nikrun/sdks/nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-linux/bin/x86_64-linux/fpc.cfg"
  },
  "output": {
    "binaryPath": "/work/my-app/bin/my-app",
    "cacheDir": "/work/my-app/.nik/cache/nikrun-fpc-sdk-3.2.4-66940ee6-x86_64-linux-debug",
    "sizeBytes": 0,
    "linesCompiled": 18
  },
  "counts": {
    "errors": 1,
    "warnings": 0,
    "notes": 0,
    "hints": 0
  },
  "diagnostics": [
    {
      "file": "/work/my-app/src/main.pas",
      "line": 12,
      "column": 3,
      "severity": "error",
      "code": 5000,
      "message": "Identifier not found \"UnknownProc\""
    }
  ]
}
```

## GitHub Actions

Use `nik build --locked` in CI to verify `nik.lock` integrity and build reproducibly across Linux, macOS, and Windows:

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Install Nikrun CLI (Unix)
        if: runner.os != 'Windows'
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          curl -fsSL https://nikrun.dev/install.sh | bash -s -- --no-modify-path
          echo "$HOME/.nikrun/bin" >> "$GITHUB_PATH"

      - name: Install Nikrun CLI (Windows)
        if: runner.os == 'Windows'
        shell: pwsh
        env:
          GH_TOKEN: ${{ github.token }}
        run: |
          irm https://nikrun.dev/install.ps1 | iex
          Add-Content -Path $env:GITHUB_PATH -Value "$env:USERPROFILE\.nikrun\bin"

      - name: Cache Nikrun SDKs & Packages
        uses: actions/cache@v4
        with:
          path: |
            ~/.nikrun/sdks
            ~/.nikrun/cache/pkg
          key: nikrun-${{ runner.os }}-${{ runner.arch }}-${{ hashFiles('nik.yaml', 'nik.lock') }}
          restore-keys: |
            nikrun-${{ runner.os }}-${{ runner.arch }}-

      - name: Install FPC SDK & Build Release
        run: |
          nik sdk install 3.2.4
          nik build -p release --locked
```

## GitLab CI

```yaml
build-linux:
  image: debian:bookworm-slim
  variables:
    NIKRUN_HOME: "$CI_PROJECT_DIR/.nikrun-home"
  cache:
    key: "nikrun-$CI_RUNNER_EXECUTABLE_ARCH"
    paths:
      - .nikrun-home/sdks/
      - .nikrun-home/cache/pkg/
  before_script:
    - apt-get update && apt-get install -y --no-install-recommends curl ca-certificates binutils
    - curl -fsSL https://nikrun.dev/install.sh | bash -s -- --no-modify-path
    - export PATH="$NIKRUN_HOME/bin:$PATH"
  script:
    - nik sdk install 3.2.4
    - nik build -p release --locked
```
