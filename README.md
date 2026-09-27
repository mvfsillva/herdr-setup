# herdr-setup

My [Herdr](https://herdr.dev) setup: keybindings, sidebar layout and zsh helpers.

## Install

```sh
git clone git@github.com:mvfsillva/herdr-setup.git ~/Developer/herdr-setup
~/Developer/herdr-setup/install.sh
```

It backs up the current `~/.config/herdr/config.toml`, writes the new one,
installs the plugins the bindings call, asks what to do with Caps Lock, adds a
source line to `.zshrc`, and reloads the running server. Re-running is fine.

If these aliases are still pasted inline in your `.zshrc`, delete that section after installing.

## What's in here

```
config/config.toml       keybindings and UI
config/agent-names.toml  sidebar rows and rename popup for herdr-agent-names
shell/herdr.zsh          aliases and helper functions
install.sh
```

## Keybindings

Everything is on `ctrl+alt+cmd+shift` so nothing collides with the shell or the editor.

| Key | Action | Key | Action |
|---|---|---|---|
| `h` `j` `k` `l` | move focus | `t` | new tab |
| `left` `down` `up` `right` | resize pane | `[` `]` | previous / next tab |
| `v` / `s` | split right / down | `r` | rename tab |
| `x` | close pane | `q` | close tab |
| `z` | zoom pane | `n` | new workspace |
| `b` | toggle Herdr's sidebar | `,` `.` | previous / next workspace |
| `d` | global goto | `w` | new worktree |
| `o` | settings | `/` | keybinding help |
| `i` | reload config | `a` | rename agent |
| `u` | throwaway shell in the pane's directory | `g` | lazygit |
| `enter` | open the pane's directory in Zed | | |

Plugin bindings, same modifiers:

| Key | Action | Key | Action |
|---|---|---|---|
| `m` | harpoon: mark pane | `e` | sidebar: explorer |
| `0` | harpoon: pick a mark | `f` | sidebar: search |
| `1` to `9` | harpoon: jump to mark | `c` | sidebar: source control |
| | | `p` | sidebar: quick open |

On the prefix: `prefix+a` renames the agent, `prefix+shift+a` opens clauth,
`prefix+b` toggles the herdr-sidebar plugin.

### Caps Lock

`install.sh` asks. Answer `1` and it remaps Caps Lock to F18 with `hidutil`,
writes a LaunchAgent so the remap survives reboots, and sets `prefix = "f18"`
in your config, which puts `prefix+a` and the rest of Herdr's prefix actions
on one key instead of `ctrl+b`. Answer `2` for hyper and it tells you where
the switch is in Raycast or Karabiner. Answer `n` and nothing is touched.

Pass `CAPSLOCK=f18`, `CAPSLOCK=hyper` or `CAPSLOCK=none` to skip the question.

The remap by hand, if you would rather not let the script do it:

```sh
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x70000006D}]}'
```

`0x700000039` is Caps Lock, `0x70000006D` is F18. Check it with
`hidutil property --get UserKeyMapping`, and undo it, plus the LaunchAgent, with:

```sh
hidutil property --set '{"UserKeyMapping":[]}'
launchctl unload ~/Library/LaunchAgents/local.capslock-f18.plist
rm ~/Library/LaunchAgents/local.capslock-f18.plist
```

`hidutil` can only reach F18. Turning Caps Lock into the four modifiers that
every binding above expects needs [Raycast](https://raycast.com) (Settings,
Advanced, Hyper Key), [Karabiner-Elements](https://karabiner-elements.pqrs.org)
or [Hammerspoon](https://www.hammerspoon.org). That is the whole difference
between the two answers: F18 is one keystroke this script can give you, hyper
needs an app.

## Aliases

| | |
|---|---|
| `h` | herdr |
| `ha` | agents, one readable line each |
| `hag` `haf` `han` `haw` | agent get / focus / rename / wait |
| `haread <agent> [lines]` | read an agent's recent output |
| `hap <agent> <msg>` | send a prompt |
| `hapw <agent> <msg>` | send a prompt and wait for the answer |
| `hareview <agent>` | ask another agent to review my diff |
| `harevieww <agent>` | same, and wait |
| `hpanes` `hpcurrent` `hplayout` `hpproc` | pane info |
| `hws` `hwnew` `hwfocus` `hwname` `hwclose` | workspaces |
| `hs` `hsattach` `hsstop` `hsdelete` | sessions |
| `hre` `hstop` | reload config / stop the server |

`ha` and the review helpers need `jq`.

## Plugins

`install.sh` installs the three GitHub ones if they are missing. Pass
`PLUGINS=none` to skip that.

- [clauth](https://github.com/uwuclxdy/clauth), a Claude Code account switcher
- [herdr-harpoon](https://github.com/KonstantinKai/herdr-harpoon), mark panes and jump to them by number
- [herdr-sidebar](https://github.com/alexarthurs/herdr-sidebar), file explorer, search, git and quick open
- `herdr-agent-names`, agent name and model in the sidebar. Not on GitHub, so
  build it with `cargo build --release`, then re-run `install.sh` so the
  sidebar block lands.
