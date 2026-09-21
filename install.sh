#!/usr/bin/env bash
# Installs this Herdr setup: config.toml, keybindings and shell helpers.
# Safe to re-run. Backs up anything it replaces.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HERDR_CONFIG_DIR:-$HOME/.config/herdr}"
CONFIG="$CONFIG_DIR/config.toml"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
MARKER="# herdr-setup"
STAMP="$(date +%Y%m%d-%H%M%S)"

say() { printf '  %s\n' "$*"; }

command -v herdr >/dev/null || {
  echo "herdr is not on PATH. Install it first: https://herdr.dev" >&2
  exit 1
}

# ── config.toml ─────────────────────────────────────────
mkdir -p "$CONFIG_DIR"
TMP="$(mktemp)"
cat "$REPO/config/config.toml" > "$TMP"

# The agent-names block needs the plugin binary. Look in the usual places,
# or take AGENT_NAMES_BIN from the environment.
BIN="${AGENT_NAMES_BIN:-}"
if [ -z "$BIN" ]; then
  for c in \
    "$HOME/Developer/herdr-agent-names/target/release/herdr-agent-names" \
    "$HOME/.config/herdr/plugins/local/herdr-agent-names/target/release/herdr-agent-names"
  do
    [ -x "$c" ] && BIN="$c" && break
  done
fi

if [ -n "$BIN" ]; then
  printf '\n' >> "$TMP"
  sed "s#{{AGENT_NAMES_BIN}}#$BIN#g" "$REPO/config/agent-names.toml" >> "$TMP"
  say "agent-names block enabled ($BIN)"
else
  say "agent-names binary not found, skipping that block"
  say "build it, then re-run with AGENT_NAMES_BIN=/path/to/herdr-agent-names"
fi

if [ -e "$CONFIG" ] && ! cmp -s "$TMP" "$CONFIG"; then
  cp "$CONFIG" "$CONFIG.bak-$STAMP"
  say "backed up the old config to config.toml.bak-$STAMP"
fi
mv "$TMP" "$CONFIG"
say "wrote $CONFIG"

# ── shell helpers ───────────────────────────────────────
if grep -qF "$MARKER" "$ZSHRC" 2>/dev/null; then
  say "shell helpers already sourced from $ZSHRC"
else
  {
    printf '\n%s\n' "$MARKER"
    printf '[ -f "%s/shell/herdr.zsh" ] && source "%s/shell/herdr.zsh"\n' "$REPO" "$REPO"
  } >> "$ZSHRC"
  say "added the source line to $ZSHRC"
fi

# ── reload ──────────────────────────────────────────────
herdr config check >/dev/null && say "config is valid"
if herdr server reload-config >/dev/null 2>&1; then
  say "running server reloaded"
fi

echo
echo "Done. Open a new shell, or run: source $ZSHRC"
