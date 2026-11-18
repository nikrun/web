#!/usr/bin/env bash
set -euo pipefail

CHANNEL="${NIKRUN_CHANNEL:-stable}"
VERSION="${NIKRUN_VERSION:-}"
MODIFY_PATH=1

while [ $# -gt 0 ]; do
    case "$1" in
        -c|--channel)
            CHANNEL="${2:-}"
            shift 2
            ;;
        -v|--version)
            VERSION="${2:-}"
            shift 2
            ;;
        --no-modify-path)
            MODIFY_PATH=0
            shift
            ;;
        -h|--help)
            echo "Usage: install.sh [-c|--channel <stable|insider>] [-v|--version <version>] [--no-modify-path]"
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            exit 1
            ;;
    esac
done

if [ "$CHANNEL" != "stable" ] && [ "$CHANNEL" != "insider" ]; then
    echo "Error: Invalid channel '$CHANNEL' (expected 'stable' or 'insider')." >&2
    exit 1
fi

REPO="nikrun/cli"
SITE_BASE_URL="https://nikrun.dev"
RAW_FALLBACK_BASE_URL="https://raw.githubusercontent.com/nikrun/web/main/src/public"

# 1. Detect host OS & CPU (including Apple Silicon running under Rosetta 2)
RAW_OS="$(uname -s)"
case "$RAW_OS" in
    Linux*)  TARGET_OS="linux" ;;
    Darwin*) TARGET_OS="darwin" ;;
    *)
        echo "Error: Unsupported operating system '$RAW_OS'." >&2
        exit 1
        ;;
esac

RAW_ARCH="$(uname -m)"
if [ "$TARGET_OS" = "darwin" ] && [ "$RAW_ARCH" = "x86_64" ]; then
    if sysctl -n hw.optional.arm64 2>/dev/null | grep -q '^1$'; then
        RAW_ARCH="arm64"
    fi
fi

case "$RAW_ARCH" in
    x86_64|amd64)   TARGET_CPU="x86_64" ;;
    aarch64|arm64)  TARGET_CPU="aarch64" ;;
    *)
        echo "Error: Unsupported CPU architecture '$RAW_ARCH'." >&2
        exit 1
        ;;
esac

TRIPLET="${TARGET_CPU}-${TARGET_OS}"

# HTTP helper supporting curl or wget
AUTH_TOKEN="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
fetch_url() {
    local url="$1"
    if command -v curl >/dev/null 2>&1; then
        if [ -n "$AUTH_TOKEN" ]; then
            curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: nikrun-installer" -H "Authorization: Bearer $AUTH_TOKEN" "$url"
        else
            curl -fsSL -H "Accept: application/vnd.github+json" -H "User-Agent: nikrun-installer" "$url"
        fi
    elif command -v wget >/dev/null 2>&1; then
        if [ -n "$AUTH_TOKEN" ]; then
            wget -qO- --header="Accept: application/vnd.github+json" --header="User-Agent: nikrun-installer" --header="Authorization: Bearer $AUTH_TOKEN" "$url"
        else
            wget -qO- --header="Accept: application/vnd.github+json" --header="User-Agent: nikrun-installer" "$url"
        fi
    else
        echo "Error: Either 'curl' or 'wget' is required." >&2
        exit 1
    fi
}

download_file() {
    local url="$1"
    local dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    else
        wget -qO "$dest" "$url"
    fi
}

# 2. Query GitHub Releases API for nikrun/cli
echo "Resolving Nikrun CLI release ($CHANNEL channel, $TRIPLET)..."

RELEASE_JSON=""
IS_LIST=0
if [ -n "$VERSION" ]; then
    RELEASE_JSON="$(fetch_url "https://api.github.com/repos/$REPO/releases/tags/$VERSION" 2>/dev/null || true)"
    if [ -z "$RELEASE_JSON" ]; then
        RELEASE_JSON="$(fetch_url "https://api.github.com/repos/$REPO/releases?per_page=100")"
        IS_LIST=1
    fi
elif [ "$CHANNEL" = "stable" ]; then
    RELEASE_JSON="$(fetch_url "https://api.github.com/repos/$REPO/releases/latest")"
else
    RELEASE_JSON="$(fetch_url "https://api.github.com/repos/$REPO/releases?per_page=50")"
    IS_LIST=1
fi

RELEASE_TAG=""
DOWNLOAD_URL=""
MANIFEST_ASSET_URL=""
EXPECTED_SHA256=""

if command -v python3 >/dev/null 2>&1; then
    PARSED="$(printf '%s' "$RELEASE_JSON" | python3 -c '
import json, sys

data = json.load(sys.stdin)
is_list = sys.argv[1] == "1"
channel = sys.argv[2]
version = sys.argv[3].strip()
triplet = sys.argv[4]

rel = None
if is_list:
    norm = "v" + version.lstrip("v") if version else ""
    for candidate in data:
        if candidate.get("draft"):
            continue
        tag = candidate.get("tag_name", "")
        if version:
            if tag == version or tag == norm or tag.startswith(norm + "-"):
                rel = candidate
                break
        else:
            if channel == "insider" and candidate.get("prerelease"):
                rel = candidate
                break
            if channel == "stable" and not candidate.get("prerelease"):
                rel = candidate
                break
else:
    rel = data

if not rel or not rel.get("tag_name"):
    sys.exit(1)

tag = rel["tag_name"]
assets = rel.get("assets") or []
zip_name = f"nik-{tag}-{triplet}.zip"
dl_url = ""
manifest_url = ""

for a in assets:
    if a.get("name") == "manifest.json":
        manifest_url = a.get("browser_download_url", "")
    if a.get("name") == zip_name:
        dl_url = a.get("browser_download_url", "")

print(tag)
print(dl_url)
print(manifest_url)
' "$IS_LIST" "$CHANNEL" "$VERSION" "$TRIPLET" || true)"

    if [ -n "$PARSED" ]; then
        RELEASE_TAG="$(printf '%s\n' "$PARSED" | sed -n '1p')"
        DOWNLOAD_URL="$(printf '%s\n' "$PARSED" | sed -n '2p')"
        MANIFEST_ASSET_URL="$(printf '%s\n' "$PARSED" | sed -n '3p')"
    fi
else
    # POSIX grep/sed fallback when python3 is unavailable
    DOWNLOAD_URL="$(printf '%s\n' "$RELEASE_JSON" | grep -o "https://github.com/$REPO/releases/download/[^\"]*nik-[^\"]*-${TRIPLET}\\.zip" | head -n 1 || true)"
    MANIFEST_ASSET_URL="$(printf '%s\n' "$RELEASE_JSON" | grep -o "https://github.com/$REPO/releases/download/[^\"]*/manifest\\.json" | head -n 1 || true)"
    if [ -n "$DOWNLOAD_URL" ]; then
        RELEASE_TAG="$(printf '%s' "$DOWNLOAD_URL" | sed -E 's#.*/download/([^/]+)/.*#\1#')"
    fi
fi

if [ -z "$RELEASE_TAG" ] || [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find a matching Nikrun CLI archive for '$TRIPLET' ($CHANNEL channel)." >&2
    exit 1
fi

# Fetch manifest.json to verify SHA-256 checksum
if [ -n "$MANIFEST_ASSET_URL" ]; then
    MANIFEST_JSON="$(fetch_url "$MANIFEST_ASSET_URL" 2>/dev/null || true)"
    if [ -n "$MANIFEST_JSON" ]; then
        if command -v python3 >/dev/null 2>&1; then
            EXPECTED_SHA256="$(printf '%s' "$MANIFEST_JSON" | python3 -c '
import json, sys
data = json.load(sys.stdin)
dl = (data.get("nik") or {}).get("downloads") or {}
info = dl.get(sys.argv[1]) or {}
if isinstance(info, dict):
    print((info.get("sha256") or "").strip().lower())
' "$TRIPLET" 2>/dev/null || true)"
        else
            EXPECTED_SHA256="$(printf '%s' "$MANIFEST_JSON" | tr -d '\n\r ' | sed -n "s/.*\"${TRIPLET}\":{[^}]*\"sha256\":\"\\([0-9a-fA-F]\\{64\\}\\)\".*/\\1/p" | tr '[:upper:]' '[:lower:]')"
        fi
    fi
fi

# 3. Download, verify SHA-256, and extract in temporary workspace
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TMP_ZIP="$TMP_DIR/nik.zip"
EXTRACT_DIR="$TMP_DIR/extracted"
mkdir -p "$EXTRACT_DIR"

echo "Downloading Nikrun CLI $RELEASE_TAG ($TRIPLET)..."
download_file "$DOWNLOAD_URL" "$TMP_ZIP"

if [ -n "$EXPECTED_SHA256" ]; then
    ACTUAL_SHA256=""
    if command -v sha256sum >/dev/null 2>&1; then
        ACTUAL_SHA256="$(sha256sum "$TMP_ZIP" | awk '{print tolower($1)}')"
    elif command -v shasum >/dev/null 2>&1; then
        ACTUAL_SHA256="$(shasum -a 256 "$TMP_ZIP" | awk '{print tolower($1)}')"
    elif command -v openssl >/dev/null 2>&1; then
        ACTUAL_SHA256="$(openssl dgst -sha256 "$TMP_ZIP" | awk '{print tolower($NF)}')"
    fi

    if [ -n "$ACTUAL_SHA256" ]; then
        if [ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]; then
            echo "Error: SHA-256 checksum mismatch! Expected $EXPECTED_SHA256, got $ACTUAL_SHA256." >&2
            exit 1
        fi
        echo "Verified SHA-256 checksum (${ACTUAL_SHA256:0:12}...)."
    fi
fi

if command -v unzip >/dev/null 2>&1; then
    unzip -q "$TMP_ZIP" -d "$EXTRACT_DIR"
elif command -v python3 >/dev/null 2>&1; then
    python3 -m zipfile -e "$TMP_ZIP" "$EXTRACT_DIR"
elif command -v bsdtar >/dev/null 2>&1; then
    bsdtar -xf "$TMP_ZIP" -C "$EXTRACT_DIR"
else
    echo "Error: 'unzip' (or 'python3') is required to extract the CLI archive." >&2
    exit 1
fi

EXTRACTED_BIN="$(find "$EXTRACT_DIR" -type f -name "nik" | head -n 1)"
if [ -z "$EXTRACTED_BIN" ]; then
    echo "Error: Archive did not contain the 'nik' executable." >&2
    exit 1
fi

# 4. Install to ~/.nikrun/bin (or $NIKRUN_HOME/bin)
NIKRUN_HOME_DIR="${NIKRUN_HOME:-$HOME/.nikrun}"
INSTALL_DIR="$NIKRUN_HOME_DIR/bin"
mkdir -p "$INSTALL_DIR"

if command -v pkill >/dev/null 2>&1; then
    pkill -x "nik" >/dev/null 2>&1 || true
elif command -v killall >/dev/null 2>&1; then
    killall "nik" >/dev/null 2>&1 || true
fi

mv -f "$EXTRACTED_BIN" "$INSTALL_DIR/nik"
chmod +x "$INSTALL_DIR/nik"

# Save local uninstall.sh copy
LOCAL_UNINSTALL="$NIKRUN_HOME_DIR/uninstall.sh"
if ! download_file "$SITE_BASE_URL/uninstall.sh" "$LOCAL_UNINSTALL" 2>/dev/null; then
    download_file "$RAW_FALLBACK_BASE_URL/uninstall.sh" "$LOCAL_UNINSTALL" 2>/dev/null || true
fi
if [ -f "$LOCAL_UNINSTALL" ]; then
    chmod +x "$LOCAL_UNINSTALL"
fi

# 5. Idempotent user shell PATH configuration
PATH_EXPORT_PATH="$INSTALL_DIR"
if [ "$NIKRUN_HOME_DIR" = "$HOME/.nikrun" ]; then
    PATH_EXPORT_PATH="\$HOME/.nikrun/bin"
fi

UPDATED_PROFILES=()
if [ "$MODIFY_PATH" -eq 1 ]; then
    case ":$PATH:" in
        *":$INSTALL_DIR:"*) ;;
        *)
            MARKER_START="# >>> nikrun >>>"
            MARKER_END="# <<< nikrun <<<"
            PROFILE_TARGETS=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile")
            TOUCHED_ANY=0

            for rc in "${PROFILE_TARGETS[@]}"; do
                if [ -f "$rc" ]; then
                    TOUCHED_ANY=1
                    if ! grep -Fq "$MARKER_START" "$rc" 2>/dev/null; then
                        printf '\n%s\nexport PATH="%s:$PATH"\n%s\n' "$MARKER_START" "$PATH_EXPORT_PATH" "$MARKER_END" >> "$rc"
                        UPDATED_PROFILES+=("$rc")
                    fi
                fi
            done

            if [ "$TOUCHED_ANY" -eq 0 ]; then
                printf '%s\nexport PATH="%s:$PATH"\n%s\n' "$MARKER_START" "$PATH_EXPORT_PATH" "$MARKER_END" >> "$HOME/.profile"
                UPDATED_PROFILES+=("$HOME/.profile")
            fi
            ;;
    esac
fi

echo ""
echo "Nikrun CLI ($RELEASE_TAG) installed to $INSTALL_DIR/nik."
if [ "${#UPDATED_PROFILES[@]}" -gt 0 ]; then
    echo "Added $INSTALL_DIR to PATH in: ${UPDATED_PROFILES[*]}"
    echo "Restart your shell or run: export PATH=\"$INSTALL_DIR:\$PATH\""
fi
