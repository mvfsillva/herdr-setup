# herdr-setup

My [Herdr](https://herdr.dev) setup: keybindings, sidebar layout and zsh helpers.

## Install

```sh
git clone <this-repo> ~/Developer/herdr-setup
~/Developer/herdr-setup/install.sh
```

It backs up the current `~/.config/herdr/config.toml`, writes the new one,
adds a source line to `.zshrc`, and reloads the running server. Re-running is fine.

If these aliases are still pasted inline in your `.zshrc`, delete that section after installing.

## What's in here

```
config/config.toml       keybindings and UI
config/agent-names.toml  sidebar rows for the herdr-agent-names plugin
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
| `z` | zoom pane | `w` | workspace picker |
| `b` | toggle sidebar | `n` | new workspace |
| `g` | global goto | `,` `.` | previous / next workspace |
| `f` | new worktree | `o` | settings |
| `m` | rename agent | `u` | reload config |

`prefix+a` opens [clauth](https://github.com/uwuclxdy/clauth), if you have it installed.

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

Not installed by this script, install them through Herdr:

- [clauth](https://github.com/uwuclxdy/clauth), a Claude Code account switcher
- `herdr-agent-names`, agent name and model in the sidebar. Build it with
  `cargo build --release`, then re-run `install.sh` so the sidebar block lands.
