# Manifest & Lockfile

Field-by-field schema reference for the **Project Manifest** (`nik.yaml`), **Lockfile** (`nik.lock`), and **SDK Manifest** (`sdk-manifest.json`).

---

## 1. Project Manifest (`nik.yaml`)

### Document Root

| Key | Type | Required | Description |
| :--- | :--- | :---: | :--- |
| `schemaVersion` | `integer` | Optional | Schema version. Must be `1` when present. |
| `program` | `object` | One of 3 | Defines an executable application (`program MyApp;`). |
| `library` | `object` | One of 3 | Defines a native shared library (`.dll` / `lib*.so` / `lib*.dylib`). |
| `package` | `object` | One of 3 | Defines a reusable source unit package (no binary output). |

### Metadata & Sections (`program` / `library` / `package`)

| Key | Type | Default | Allowed On | Description |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | Directory name | All | Project or package identifier. |
| `version` | `string` | `"0.1.0"` | All | SemVer project version. |
| `description` | `string` | `""` | All | Short summary. |
| `license` | `string` | `""` | All | SPDX license identifier (e.g. `"MIT"`, `"GPL-3.0-or-later"`). |
| `repository` | `string` | `""` | All | Source repository URL. |
| `authors` | `string[]` | `[]` | All | Author names / contacts. |
| `entry` | `string` | *(required)* | `program`, `library` | Relative path to main Pascal source file (disallowed on `package`). |
| `output` | `string` | `"bin/<name>"` | `program`, `library` | Output binary path (OS extension added automatically when omitted). |
| `toolchain` | `object` | *(required)* | All | Compiler version and target selection. |
| `build` | `object` | `{}` | All | Compiler dialect, paths, checks, warnings, and optimization flags. |
| `dependencies` | `object` | `{}` | All | Map of dependency aliases to paths, Git URLs, archives, or mappings. |
| `test` | `object` | `{}` | All | Test configuration (`entry`, `output`, `toolchain`, `build`, `dependencies`). |
| `targets` | `object` | `{}` | All | Map of target selectors (`windows`, `unix`, `linux`, `darwin`, `x86_64`, `aarch64`, `<cpu>-<os>`) to section overrides. |
| `profiles` | `object` | `{}` | All | Map of profile names (`debug`, `release`, or custom names) to section overrides. |

### `toolchain`

| Key | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `fpc` | `string` | *(required)* | Exact `MAJOR.MINOR.PATCH` Free Pascal version (e.g. `3.2.2`, `3.2.4`, `3.2.5`, `3.3.1`). |
| `target` | `string` | `"native"` | `"native"` or explicit `<cpu>-<os>` triplet (`x86_64-win64`, `aarch64-win64`, `x86_64-linux`, `aarch64-linux`, `x86_64-darwin`, `aarch64-darwin`). |

### `build` & Compiler Flags

Every `nik build` invocation starts with `-n @<sdk>/fpc.cfg -vq -viwn -vb -l-` plus `-FU<cacheDir>` and `-FE<outDir>`. Additional `build` keys map deterministically to `ppc*` flags:

| Key | Type / Values | Default | Generated Compiler Flags |
| :--- | :--- | :--- | :--- |
| `mode` | `objfpc` \| `delphi` \| `delphiunicode` \| `fpc` \| `tp` \| `macpas` \| `iso` \| `extendedpascal` | `objfpc` | `-M<mode>` |
| `modeSwitches` | `string[]` (e.g. `advancedRecords`, `typeHelpers`) | `[]` | `-M<switch>` per item |
| `longStrings` | `boolean` | `true` | `true` → `-Sh`, `false` → `-Sh-` |
| `cOperators` | `boolean` | *(unset)* | `true` → `-Sc`, `false` → `-Sc-` |
| `subsystem` | `console` \| `gui` | `console` | On `win64` executables: `gui` → `-WG`, `console` → `-WG-` |
| `pic` | `auto` \| `true` \| `false` | `auto` | `true` → `-Cg`, `false` → `-Cg-` (`auto` enables `-Cg` for `library` on Unix) |
| `cpuType` | `string` (e.g. `COREAVX2`) | `native` | `-Cp<cpuType>` (when not `native` / `default`) |
| `fpuType` | `string` (e.g. `AVX2`) | `default` | `-Cf<fpuType>` (when not `default`) |
| `stackSize` | `integer` (bytes) | *(unset)* | `-Cs<bytes>` |
| `unitPaths` | `string[]` | `[]` | `-Fu<path>` |
| `includePaths` | `string[]` | `[]` | `-Fi<path>` |
| `libraryPaths` | `string[]` | `[]` | `-Fl<path>` |
| `objectPaths` | `string[]` | `[]` | `-Fo<path>` |
| `resourcePaths` | `string[]` | `[]` | Adds to both `-Fi<path>` and `-Fo<path>` |
| `defines` | `string[]` | Profile-dependent | `-d<SYMBOL>` |
| `undefines` | `string[]` | `[]` | `-u<SYMBOL>` (emitted before `-d`) |
| `debugInfo` | `none` \| `lineinfo` \| `dwarf2` \| `dwarf3` \| `stabs` \| `external` \| `true` \| `false` | `dwarf2` (`debug`), `none` (`release`) | `none`/`false` → `-g-`; `lineinfo` → `-gl`; `dwarf2`/`true` → `-gl -gw2`; `dwarf3` → `-gl -gw3`; `stabs` → `-gl -gs`; `external` → `-gl -gw2 -Xg` |
| `heaptrc` | `boolean` | `false` (`true` in `test`) | `true` → `-gh -gl` |
| `assertions` | `boolean` | `true` (`debug`), `false` (`release`) | `true` → `-Sa`, `false` → `-Sa-` |
| `checks` | `Array<range \| overflow \| io \| stack \| object \| all \| none>` | `[range, overflow, io]` in `debug` | `-Cr`/`-Cr-`, `-Co`/`-Co-`, `-Ci`/`-Ci-`, `-Ct`/`-Ct-`, `-CR`/`-CR-` |
| `warnings.asErrors` | `boolean` | `false` | `true` → `-Sew` |
| `warnings.hints` | `boolean` | *(unset)* | `true` → `-vh`, `false` → `-vh-` |
| `warnings.notes` | `boolean` | `true` | `false` → `-vn-` |
| `warnings.suppress` | `Array<integer \| string>` | `[]` | `-vm<id1>,<id2>,...` |
| `optimization` | `0..4` \| `none` \| `default` \| `true` \| `false` | `2` in `release` | `0`/`none`/`false` → `-O-`; `1..4` → `-O1`..`-O4`; `default`/`true` → `-O2` |
| `smartLink` | `boolean` | `true` in `release` | `true` → `-CX -XX`, `false` → `-CX- -XX-` |
| `stripSymbols` | `boolean` | `true` in `release` | `true` → `-Xs`, `false` → `-Xs-` |
| `linkLibraries` | `string[]` | `[]` | `-k-l<lib>` |
| `linkerArgs` | `string[]` | `[]` | `-k<arg>` |
| `fpcArgs` | `string[]` | `[]` | Appended verbatim before the entry source file |

### `dependencies` Mapping Keys

When a dependency in `dependencies:` is written as a YAML mapping instead of a compact string:

| Key | Type | Description |
| :--- | :--- | :--- |
| `url` | `string` | Git repository URL or remote `.zip`/`.tar.gz`/`.tgz` archive URL. |
| `path` | `string` | Local directory or archive path. When combined with `url`, overrides `url` across the entire dependency graph with the local path. |
| `version` | `string` | SemVer constraint for Git tags (e.g. `^0.2.0`, `~1.4.0`, `>=1.0.0 <2.0.0`). Mutually exclusive with `rev`. |
| `rev` | `string` | Exact Git commit SHA (7–40 hex characters). Mutually exclusive with `version`. |
| `subpath` | `string` | Relative subdirectory inside a multi-package repository or archive. |
| `sha256` | `string` | Expected 64-character hex SHA-256 checksum for archive dependencies. |
| `unitPaths` | `string[]` | Explicit unit search paths (relative to package root) for legacy packages that do not ship `nik.yaml`. |
| `includePaths` | `string[]` | Explicit include search paths for legacy packages without `nik.yaml`. |

---

## 2. Lockfile (`nik.lock`)

Generated and maintained automatically by `nik build`, `nik pkg fetch`, and `nik pkg update`.

| Key | Type | Description |
| :--- | :--- | :--- |
| `lockVersion` | `integer` | Lockfile schema version (`1`). |
| `packages[].id` | `string` | Canonical package identifier (`<normalized-url-or-path>[#<subpath>]`). |
| `packages[].kind` | `git` \| `archive` \| `local-archive` | Resolved dependency transport kind. |
| `packages[].url` | `string` | Remote Git repository or archive URL (when remote). |
| `packages[].path` | `string` | Relative local archive path (when `local-archive`). |
| `packages[].subpath` | `string` | Optional subdirectory within the repository or archive. |
| `packages[].version` | `string` | Resolved SemVer version (when resolved from a SemVer tag). |
| `packages[].rev` | `string` | Full 40-character Git commit SHA (for `kind: git`). |
| `packages[].integrity` | `string` | Cross-platform file-tree hash `sha256-<64hex>` (for `kind: git`). |
| `packages[].sha256` | `string` | Raw archive SHA-256 hex digest (for `archive` and `local-archive`). |

---

## 3. SDK Manifest (`sdk-manifest.json`)

Located at the root of every installed Free Pascal SDK (`~/.nikrun/sdks/<sdkId>/sdk-manifest.json`).

| Key | Type | Description |
| :--- | :--- | :--- |
| `schemaVersion` | `integer` | SDK manifest schema version (`1`). |
| `sdkId` | `string` | Unique SDK folder identifier (`nikrun-fpc-sdk-<ver>-<shortSha>-<cpu>-<os>`). |
| `fpcVersion` | `string` | Exact compiler version extracted from `compiler/version.pas`. |
| `gitRepo` | `string` | Upstream Free Pascal Git repository URL used for the build. |
| `gitRef` | `string` | Tracked Git branch or tag (`release_3_2_4-branch`, `fixes_3_2`, `main`, …). |
| `gitCommit` | `string` | Exact 40-character upstream Git commit SHA. |
| `targetOs` | `string` | Target OS (`win64`, `linux`, `darwin`). |
| `targetCpu` | `string` | Target CPU (`x86_64`, `aarch64`). |
| `targetTriplet` | `string` | `<targetCpu>-<targetOs>`. |
| `builtAtUtc` | `string` | ISO-8601 UTC build timestamp. |
| `paths.binDir` | `string` | Relative path to toolchain binaries and generated `fpc.cfg`. |
| `paths.ppcBinary` | `string` | Relative path to the direct CPU compiler backend (`ppcx64` / `ppca64`). |
| `paths.fpcBinary` | `string` | Relative path to the upstream `fpc` wrapper binary. |
| `paths.fpcmkcfgBinary` | `string` | Relative path to `fpcmkcfg`. |
| `paths.unitsDir` | `string` | Relative path to precompiled `.ppu` units (`units/<cpu>-<os>`). |
| `paths.rtlSourceDir` | `string` | Relative path to bundled RTL sources (`source/rtl`). |
| `paths.packagesSourceDir` | `string` | Relative path to bundled standard package sources (`source/packages`). |
