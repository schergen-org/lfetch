<p align="center"><img width="671" height="193" alt="2026-02-25_13-26-32" src="https://github.com/user-attachments/assets/8d211559-387c-49f0-9980-46c4ab6b2103" /></p>

[![Lean Action CI](https://github.com/schergen-org/lfetch/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/schergen-org/lfetch/actions/workflows/lean_action_ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

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
$HOME/.config/lftech/config
```

Put one entry per line. The order is arbitrary and determines the output order. You can list only a few items or all of them.

### Available keys

- `OS`
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

```text
user
hostname
OS
kernel
arch
shell
terminal
uptime
ram
cpu
battery
```

Only the keys present in the config are printed, in the same order as listed.




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



## Roadmap
Planned improvements:

- Better / nicer formatting of the output (intended to use the Lean library **Leansi**)
- More customization options (e.g. configurable colors)
- ASCII art support (neofetch-style)
