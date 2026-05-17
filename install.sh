#!/usr/bin/env bash
# curltime installer
#
#   curl -fsSL https://raw.githubusercontent.com/arastu/curltime/main/install.sh | bash
#
# Env vars:
#   CURLTIME_PREFIX   install dir (default: auto: /usr/local/bin or ~/.local/bin)
#   CURLTIME_REF      git ref / branch / tag to install (default: main)

set -euo pipefail

REPO_RAW="${CURLTIME_REPO_RAW:-https://raw.githubusercontent.com/arastu/curltime}"
REF="${CURLTIME_REF:-main}"
SRC="${REPO_RAW}/${REF}/curltime"

# colours
if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; D=$'\033[2m'; N=$'\033[0m'
else B=""; G=""; Y=""; R=""; D=""; N=""; fi

say() { printf "%s\n" "$*"; }

pick_prefix() {
  if [ -n "${CURLTIME_PREFIX:-}" ]; then echo "$CURLTIME_PREFIX"; return; fi
  for d in /usr/local/bin "$HOME/.local/bin"; do
    if [ -d "$d" ] && [ -w "$d" ]; then echo "$d"; return; fi
    if [ -d "$d" ]; then echo "$d"; return; fi  # may need sudo
  done
  echo "$HOME/.local/bin"
}

PREFIX="$(pick_prefix)"
DEST="${PREFIX}/curltime"
mkdir -p "$PREFIX" 2>/dev/null || true

SUDO=""
if [ ! -w "$PREFIX" ]; then SUDO="sudo"; fi

say "${B}curltime installer${N}"
say "  source : ${D}${SRC}${N}"
say "  target : ${D}${DEST}${N}"
[ -n "$SUDO" ] && say "  ${Y}note${N}  : ${PREFIX} not writable — will use sudo"

TMP="$(mktemp -t curltime.XXXXXX)"
trap 'rm -f "$TMP"' EXIT

if ! curl -fsSL "$SRC" -o "$TMP"; then
  say "${R}error${N}: failed to download $SRC"
  exit 1
fi

if ! head -1 "$TMP" | grep -q '^#!'; then
  say "${R}error${N}: downloaded file does not look like a script"
  exit 1
fi

$SUDO install -m 0755 "$TMP" "$DEST"

say "${G}installed${N} ${DEST}"

if ! command -v curltime >/dev/null 2>&1; then
  say "${Y}warning${N}: ${PREFIX} is not on your PATH"
  say "  add this to your shell rc:"
  say "    export PATH=\"${PREFIX}:\$PATH\""
fi

say ""
"$DEST" --version
say "${D}try:${N} curltime https://example.com"
