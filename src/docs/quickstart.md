# Quickstart

Go from a fresh `nik` installation to a compiled native Object Pascal executable in four commands.

## 1. Install a Free Pascal SDK

Download and verify Free Pascal `3.2.4` into `~/.nikrun/sdks/`:

```bash
nik sdk install 3.2.4
```

*(To try trunk features such as anonymous functions, install `3.3.1` alongside it with `nik sdk install 3.3.1`.)*

## 2. Initialize a Project

Scaffold a new executable project directory:

```bash
nik init hello-nikrun
cd hello-nikrun
```

`nik init` creates a clean project layout:

```text
hello-nikrun/
├── .gitignore       # Ignores bin/ and .nik/
├── nik.yaml         # Project Manifest
└── src/
    └── main.pas     # Entry program source
```

Generated `nik.yaml`:

```yaml
schemaVersion: 1

program:
  name: hello-nikrun
  version: 0.1.0
  entry: src/main.pas
  output: bin/hello-nikrun

  toolchain:
    fpc: 3.2.4

  build:
    mode: objfpc
    longStrings: true
    unitPaths: [src]
```

## 3. Build the Project

Compile using the default `debug` profile:

```bash
nik build
```

Compile an optimized `release` binary (smart-linked and stripped):

```bash
nik build -p release
```

Intermediate `.ppu` and `.o` files are isolated in `.nik/cache/`, and the compiled executable is written to `bin/`:

::: code-group

```powershell [Windows (PowerShell)]
.\bin\hello-nikrun.exe
```

```bash [Linux / macOS]
./bin/hello-nikrun
```

:::

## 4. Open in VS Code

Install the official **Nikrun — Free Pascal & Object Pascal** extension in VS Code and open the `hello-nikrun` folder. `nik lsp` starts automatically using `nik.yaml`—giving you live compiler diagnostics, RTL code navigation, and status-bar switchers for SDK versions and profiles with zero extra configuration.
