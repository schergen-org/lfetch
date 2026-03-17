<p align="center"><img width="671" height="193" alt="2026-02-25_13-26-32" src="https://github.com/user-attachments/assets/8d211559-387c-49f0-9980-46c4ab6b2103" /></p>

[![Lean Action CI](https://github.com/schergen-org/lfetch/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/schergen-org/lfetch/actions/workflows/lean_action_ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<a href="https://github.com/schergen-org/lfetch/releases/tag/v0.1.0" alt="Version 0.1.0">
        <img src="https://img.shields.io/badge/version-0.1.0-blue" /></a>

<h1 align="center">lfetch</h1>
<p align="center">A simple system information tool written in LEAN 4</p><br>
<sup><p align="center">Functionally inspired by <a href="https://github.com/dylanaraps/pfetch">pfetch</a>, <a href="https://github.com/dylanaraps/neofetch">neofetch</a>, ...</p></sup><br>

<img width="490" height="302" alt="2026-02-25_13-43-38" src="https://github.com/user-attachments/assets/510591db-4058-4832-9157-b05b66c6bfb9" align="right" />


`lfetch` is a small “fetch”-style system information tool, similar in spirit to **neofetch**, but written in **Lean 4**. It prints a set of basic system details in the terminal.

What gets printed (and in what order) is controlled through a simple config file.

<br>
<br>
<br>
<br>
<br>
<br>

## Configuration

`lfetch` reads its configuration from:

```text
$HOME/.config/lfetch/config.json
```

The config uses JSON with two top-level sections:
- `colors` (e.g. `primary`, `secondary`, `accent`, `muted`)
- `groups` (optional `title` and an ordered list of `infos`)

Only the `infos` listed in `groups` are printed, in that exact order.

### Color roles

The four configured colors have fixed rendering roles throughout the UI:

- `primary`: box borders and group titles
- `secondary`: info labels in the left column
- `accent`: highlights and widgets, especially the `ProgressBar` used by `drive`, `ram`, and `battery`
- `muted`: secondary details and placeholder/fallback values such as `unknown`

This keeps the layout readable even when individual infos render richer `Leansi` documents instead of plain text.

### Available keys

- `os`
- `drive`
- `user`
- `shell`
- `home`
- `hostname`
- `kernel`
- `arch`
- `terminal`
- `locale`
- `uptime`
- `ram`
- `cpu`
- `battery`

### Example config

```json
{
  "colors": {
    "primary": "#FFFFFF",
    "secondary": "#C0C0C0",
    "accent": "#4FA3FF",
    "muted": "#808080"
  },
  "groups": [
    {
      "title": null,
      "infos": ["user", "hostname", "os"]
    },
    {
      "title": "System",
      "infos": ["kernel", "arch", "uptime", "ram", "cpu", "battery"]
    }
  ]
}
```

## Architecture

The codebase is split into clear layers:

- `Lfetch/Config/*`: config schema, defaults, and loading from `~/.config/lfetch/config.json`
- `Lfetch/Domain/*`: core domain types (currently `InfoKey`)
- `Lfetch/Runtime/*`: runtime wiring/dispatch (mapping `InfoKey -> fetch`)
- `Lfetch/Info/*`: concrete info providers (`OS`, `CPU`, `RAM`, ...), now returning `List (Doc Style)` instead of `List String`
- `Lfetch/Output/*`: rendering and layout with `Leansi`

This keeps configuration, domain modeling, info collection, and terminal rendering separated.

## Rendering

`lfetch` now builds its output on top of **Leansi**. Each info provider returns structured `Doc` values, so rendering can preserve styling and widget composition until the final terminal output stage.

Current conventions:

- Simple infos such as `user`, `os`, `kernel`, or `cpu` return plain `Doc.text` lines.
- Missing or unavailable values are rendered as muted italic docs.
- `drive`, `ram`, and `battery` use `Leansi.progressBar`, with the configured `accent` color used for the active bar state and `muted` used for auxiliary text.
- Group boxes and warning boxes are still rendered centrally in `Lfetch/Output/Render.lean`.


## Installation (Linux)

The GitHub Release contains a prebuilt executable called `lfetch`. To be able to run it by simply typing `lfetch` in the terminal, the file must:

1. be executable (`chmod +x`)
2. be placed in a directory that is in your `$PATH` (e.g. `~/.local/bin` or `/usr/local/bin`)

### Option A (recommended, no sudo): `~/.local/bin`

1) Download `lfetch` from the GitHub Release (e.g. to `~/Downloads`)

2) Create the target directory:
```bash
mkdir -p ~/.local/bin
```

3) Make it executable and move it into place:
```bash
chmod +x ~/Downloads/lfetch
mv ~/Downloads/lfetch ~/.local/bin/lfetch
```

4) Ensure `~/.local/bin` is in your `PATH`:
```bash
echo $PATH
```

If it’s not listed, add it to your shell config:

**bash:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**zsh:**
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Now you can run:
```bash
lfetch
```

---

### Option B (system-wide, with sudo): `/usr/local/bin`

1) Download `lfetch` from the GitHub Release (e.g. to `~/Downloads`)

2) Install it system-wide:
```bash
chmod +x ~/Downloads/lfetch
sudo mv ~/Downloads/lfetch /usr/local/bin/lfetch
```

Run:
```bash
lfetch
```

---
