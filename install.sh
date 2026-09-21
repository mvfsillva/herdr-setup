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

# ── caps lock (optional) ────────────────────────────────
# CAPSLOCK=f18|hyper|none skips the prompt, for unattended runs.
CAPS="${CAPSLOCK:-}"
if [ -z "$CAPS" ]; then
  if [ -t 0 ]; then
    echo
    echo "  Caps Lock is wasted space. Remap it?"
    echo "    1  F18, and set Herdr's prefix to it, so prefix+a and friends"
    echo "       stop needing ctrl+b. Done here, by hidutil."
    echo "    2  Hyper (ctrl+alt+cmd+shift), which is what every binding in"
    echo "       this config expects. Needs Raycast or Karabiner."
    echo "    n  Leave it alone. Prefix stays ctrl+b."
    printf '  [1/2/n] '
    read -r answer || answer=n
    case "$answer" in
      1) CAPS=f18 ;;
      2) CAPS=hyper ;;
      *) CAPS=none ;;
    esac
  else
    CAPS=none
  fi
fi

CAPS_SRC=0x700000039   # caps lock
CAPS_DST=0x70000006D   # f18
AGENTS_DIR="${LAUNCH_AGENTS_DIR:-$HOME/Library/LaunchAgents}"
PLIST="$AGENTS_DIR/local.capslock-f18.plist"

case "$CAPS" in
  f18)
    MAPPING="{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":$CAPS_SRC,\"HIDKeyboardModifierMappingDst\":$CAPS_DST}]}"
    hidutil property --set "$MAPPING" >/dev/null
    say "caps lock is now F18"

    mkdir -p "$AGENTS_DIR"
    cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.capslock-f18</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>$MAPPING</string>
  </array>
  <key>RunAtLoad</key><true/>
</dict>
</plist>
PLISTEOF
    launchctl unload "$PLIST" >/dev/null 2>&1 || true
    launchctl load "$PLIST" >/dev/null 2>&1 || true
    say "it will survive reboots ($PLIST)"

    # point Herdr's prefix at the new key
    if ! grep -q '^prefix = ' "$CONFIG"; then
      awk '/^\[keys\]$/ && !done { print; print "prefix = \"f18\"  # caps lock, remapped by install.sh"; done=1; next } { print }' \
        "$CONFIG" > "$CONFIG.tmp" && mv "$CONFIG.tmp" "$CONFIG"
      say 'set prefix = "f18"'
    fi
    ;;
  hyper)
    if [ -d "/Applications/Raycast.app" ]; then
      say "Raycast is installed: Settings, Advanced, Hyper Key, pick Caps Lock"
    elif [ -d "/Applications/Karabiner-Elements.app" ]; then
      say "Karabiner is installed: map caps_lock to left_control+left_option+left_command+left_shift"
    else
      say "no Raycast or Karabiner found, see the README for both routes"
    fi
    say "every binding in this config already expects hyper, so nothing to change here"
    ;;
  *)
    say "caps lock left alone"
    ;;
esac

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
