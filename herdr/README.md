# herdr config

My [herdr](https://herdr.dev) configuration, kept here so it travels with the nvim config.

## Install on a new machine

```bash
scripts/install-herdr.sh            # symlink config.toml, clone the picker plugin
scripts/install-herdr.sh --dry-run  # show what it would do
scripts/install-herdr.sh --copy     # copy instead of symlink
scripts/install-herdr.sh --no-plugins
```

The script backs up anything already in `~/.config/herdr`, runs `herdr config check`, restores the
backup if the config is rejected, and reloads a running server (`herdr server reload-config`) without
disturbing panes.

## Files

| File | Purpose |
|---|---|
| `config.toml` | The whole config. Symlinked to `~/.config/herdr/config.toml`, so edits here are what you commit. |
| `plugins.json.template` | Registration for the `project-picker` plugin. `{{PLUGIN_ROOT}}` is replaced with the local checkout path at install time. |

Runtime state (`session.json`, `herdr-*.log`, `*.sock`, `release-notes.json`, `.plugins.lock`) is
deliberately not checked in — herdr regenerates it per machine.

The `project-picker` plugin itself lives in its own repo,
[kcnklub/herdr-project-pickr](https://github.com/kcnklub/herdr-project-pickr). `plugins.json` only
stores an absolute path to a checkout, which is why it is rendered from a template instead of
committed directly. Override where it lands with `HERDR_PICKER_DIR=... scripts/install-herdr.sh`
(default `~/projects/herdr-project-picker`).

## Keybindings

The leader is `ctrl+w`, mirroring the `C-w` key table in `~/.config/tmux/tmux.conf` (itself a port of
my old Ghostty hotkeys). `ctrl+w ctrl+w` sends a literal `ctrl+w` to the pane.

| Keys | Action |
|---|---|
| `ctrl+w v` / `ctrl+w s` | split right / split down |
| `ctrl+w h` `j` `k` `l` | focus pane left/down/up/right (also `ctrl+alt+<arrows>`) |
| `ctrl+t` / `ctrl+n` / `ctrl+p` | new / next / previous tab (prefix-less, as in tmux) |
| `ctrl+alt+n` / `ctrl+alt+p` | next / previous agent |
| `ctrl+alt+1..9` | jump straight to agent N |
| `ctrl+w 1..9`, `alt+1..9` | switch tab |
| `ctrl+w x` / `ctrl+w z` / `ctrl+w ;` | close pane / zoom / last pane |
| `ctrl+w &` | close tab (tmux's `kill-window` key) |
| `ctrl+w shift+c/r/k/p/n` | workspace new/rename/close/prev/next |
| `ctrl+w q` / `ctrl+w ?` | reload config / help |

`ctrl+n` and `ctrl+p` are swallowed from panes, the same tradeoff the tmux `bind -n` bindings made.
`settings` sits on `ctrl+w shift+s` because herdr's default `prefix+s` is split-down here.
