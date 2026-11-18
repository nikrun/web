#!/usr/bin/env bash
set -euo pipefail

PURGE=0
KEEP_DATA=0
NON_INTERACTIVE=0

while [ $# -gt 0 ]; do
    case "$1" in
        --purge)
            PURGE=1
            shift
            ;;
        --keep-data)
            KEEP_DATA=1
            shift
            ;;
        --non-interactive)
            NON_INTERACTIVE=1
            shift
            ;;
        -h|--help)
            echo "Usage: uninstall.sh [--purge | --keep-data] [--non-interactive]"
            exit 0
            ;;
        *)
            echo "Error: Unknown option '$1'" >&2
            exit 1
            ;;
    esac
done

NIKRUN_HOME_DIR="${NIKRUN_HOME:-$HOME/.nikrun}"
INSTALL_DIR="$NIKRUN_HOME_DIR/bin"
EXECUTABLE="$INSTALL_DIR/nik"
LOCAL_UNINSTALL="$NIKRUN_HOME_DIR/uninstall.sh"

echo "Uninstalling Nikrun CLI..."

# 1. Stop running nik instances (e.g. nik lsp) and remove binary
if command -v pgrep >/dev/null 2>&1 && pgrep -x "nik" >/dev/null 2>&1; then
    echo "Stopping running nik instances..."
    pkill -x "nik" >/dev/null 2>&1 || true
    sleep 1
elif command -v killall >/dev/null 2>&1; then
    killall "nik" >/dev/null 2>&1 || true
fi

if [ -f "$EXECUTABLE" ]; then
    rm -f "$EXECUTABLE"
    echo "Removed $EXECUTABLE."
fi

if [ -d "$INSTALL_DIR" ] && [ -z "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
    rmdir "$INSTALL_DIR" 2>/dev/null || true
fi

# 2. Clean # >>> nikrun >>> PATH block from shell profiles
MARKER_START="# >>> nikrun >>>"
MARKER_END="# <<< nikrun <<<"
for rc in "$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"; do
    if [ -f "$rc" ] && grep -Fq "$MARKER_START" "$rc" 2>/dev/null; then
        TMP_RC="$(mktemp)"
        awk -v start="$MARKER_START" -v end="$MARKER_END" '
            $0 == start { skip = 1; next }
            $0 == end   { skip = 0; next }
            !skip       { print }
        ' "$rc" > "$TMP_RC"
        cat "$TMP_RC" > "$rc"
        rm -f "$TMP_RC"
        echo "Removed Nikrun PATH block from $rc."
    fi
done

# 3. Ask user whether to also remove SDKs, cache, and config inside ~/.nikrun
if [ -d "$NIKRUN_HOME_DIR" ]; then
    OTHER_ITEMS=()
    while IFS= read -r entry; do
        [ -z "$entry" ] && continue
        if [ "$entry" != "uninstall.sh" ] && [ "$entry" != "uninstall.ps1" ]; then
            OTHER_ITEMS+=("$entry")
        fi
    done < <(ls -A "$NIKRUN_HOME_DIR" 2>/dev/null || true)

    REMOVE_ALL=0
    if [ "${#OTHER_ITEMS[@]}" -eq 0 ]; then
        REMOVE_ALL=1
    elif [ "$PURGE" -eq 1 ]; then
        REMOVE_ALL=1
    elif [ "$KEEP_DATA" -eq 1 ]; then
        REMOVE_ALL=0
    elif [ "$NON_INTERACTIVE" -eq 0 ] && [ -z "${CI:-}" ] && [ -t 1 ] && [ -r /dev/tty ]; then
        echo ""
        echo "Additional toolchain data found in $NIKRUN_HOME_DIR: ${OTHER_ITEMS[*]}"
        printf "Also remove installed Free Pascal SDKs, cache, and config in '%s'? [y/N]: " "$NIKRUN_HOME_DIR" > /dev/tty
        IFS= read -r ANSWER < /dev/tty || ANSWER=""
        case "$ANSWER" in
            y|Y|yes|YES|j|J|ja|JA)
                REMOVE_ALL=1
                ;;
        esac
    fi

    if [ "$REMOVE_ALL" -eq 1 ]; then
        rm -rf "$NIKRUN_HOME_DIR"
        echo "Removed $NIKRUN_HOME_DIR completely."
    else
        rm -f "$LOCAL_UNINSTALL" 2>/dev/null || true
        echo "Kept SDKs and user data in $NIKRUN_HOME_DIR."
    fi
fi

echo ""
echo "Nikrun CLI has been uninstalled. Restart open shells for PATH changes to take effect."
