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

## Current Scope

The implementation is Linux-focused at the moment. Several providers read Linux-specific files such as `/etc/os-release`, `/proc/uptime`, `/proc/cpuinfo`, `/proc/meminfo`, and `/sys/class/power_supply`, so the current codebase should not be described as cross-platform.

The rendered output consists of:

- a fixed ASCII logo on the left
- one boxed section per configured group on the right
- an additional warning box if the config file exists but cannot be parsed or decoded

## Build And Run

The repository is configured for:

- Lean toolchain `leanprover/lean4:v4.28.0`
- package version `0.1.0`
- executable target `lfetch`
- library target `Lfetch`

Build from source with Lake:

```bash
lake build
lake exe lfetch
```

Repository-backed note about dependencies:

- `leansi` is currently required via the SSH URL `git@github.com:schergen-org/Leansi.git` in [`lakefile.toml`](/home/benjamin/Repos/lfetch/lakefile.toml). On a fresh machine, fetching dependencies therefore requires GitHub SSH access or a local change to that dependency URL.

## Configuration

`lfetch` reads:

```text
$HOME/.config/lfetch/config.json
```

Load behavior in the current code:

- if the file does not exist, `lfetch` silently uses the built-in default config
- if JSON parsing fails, `lfetch` falls back to the default config and renders a warning box
- if JSON shape decoding fails, `lfetch` falls back to the default config and renders a warning box

### JSON Shape

The config schema is defined in [`Lfetch/Config/Types.lean`](/home/benjamin/Repos/lfetch/Lfetch/Config/Types.lean).

The JSON decoder expects the correctly spelled field names `thresholdLow`, `thresholdMid`, and `thresholdHigh`.

### Color Fields

The configured colors are used as follows:

- `primary`: box borders, group titles, and parts of the ASCII logo
- `secondary`: info labels and parts of the ASCII logo
- `accent`: parts of the ASCII logo and the warning box title/border
- `muted`: fallback values such as `unknown` and secondary detail text
- `thresholdLow`, `thresholdMid`, `thresholdHigh`: threshold colors for progress bars

Progress bars are used by:

- `ram`
- `battery`
- `drive`

For `ram` and `drive`, the bar colors grow from low to high usage. For `battery`, the color mapping is inverted so high charge is shown as good and low charge as bad.

### Groups

Each group contains:

- `title : Option String`
- `padding : Option Nat`
- `infos : List InfoKey`

`padding` inserts blank lines between the rows of that group. If it is omitted, rows are rendered directly one after another.

### Default Config

The built-in default config from [`Lfetch/Config/Defaults.lean`](/home/benjamin/Repos/lfetch/Lfetch/Config/Defaults.lean) is:

```json
{
  "colors": {
    "primary": "#94e2d5",
    "secondary": "#fab387",
    "accent": "#89b4fa",
    "muted": "#585b70",
    "thresholdLow": "#a6e3a1",
    "thresholdMid": "#f9e2af",
    "thresholdHigh": "#f38ba8"
  },
  "groups": [
    {
      "title": "Overview",
      "infos": ["user", "os", "kernel", "uptime", "shell", "cpu", "arch", "palette"]
    },
    {
      "title": "Resources",
      "padding": 1,
      "infos": ["ram", "battery", "drive"]
    }
  ]
}
```

## Available Info Keys

The currently supported keys are defined in [`Lfetch/Domain/InfoKey.lean`](/home/benjamin/Repos/lfetch/Lfetch/Domain/InfoKey.lean).

| Key | Source in current code | Output notes |
| --- | --- | --- |
| `dummy` | placeholder module | prints `TODO(dummy-info)` |
| `palette` | built-in `leansi` color swatches | renders two rows of color blocks |
| `os` | `/etc/os-release`, fallback `uname -sr` | prints distro or kernel-style fallback |
| `drive` | `df -h` | shows mount point, used/total, and a progress bar; filters out pseudo-filesystems |
| `user` | `USER`, fallback `LOGNAME` | prints the current user |
| `shell` | `SHELL` | prints the shell path |
| `home` | `HOME` | prints the home directory |
| `hostname` | `/etc/hostname`, fallback `uname -n` | prints the host name |
| `kernel` | `uname -sr` | prints kernel name and release |
| `arch` | `uname -m` | prints machine architecture |
| `terminal` | `TERM`, fallback `TERM_PROGRAM` | prints terminal identifier |
| `locale` | `LANG`, fallback `LC_ALL` | prints locale setting |
| `uptime` | `/proc/uptime` | formatted as `Xm`, `Hh Mm`, or `Dd Hh Mm` |
| `cpu` | `/proc/cpuinfo` | first matching key among `model name`, `Hardware`, `Processor` |
| `ram` | `/proc/meminfo` | prints used/total GiB and a progress bar |
| `battery` | `/sys/class/power_supply/BAT*` | prints one entry per battery with status and a progress bar |

Fallback behavior varies per provider:

- missing values commonly render as muted italic `unknown`
- `battery` renders `No battery found` if no `BAT*` entries exist
- `drive` renders `error running df` if `df` fails and `no drives found` if no real filesystems remain after filtering

## Repository Layout

- [`Lfetch/Config`](/home/benjamin/Repos/lfetch/Lfetch/Config) contains config types, defaults, and loading
- [`Lfetch/Domain`](/home/benjamin/Repos/lfetch/Lfetch/Domain) contains domain types such as `InfoKey`
- [`Lfetch/Runtime`](/home/benjamin/Repos/lfetch/Lfetch/Runtime) maps keys to provider modules
- [`Lfetch/Info`](/home/benjamin/Repos/lfetch/Lfetch/Info) contains the individual info providers
- [`Lfetch/Output`](/home/benjamin/Repos/lfetch/Lfetch/Output) contains report rendering

## License

This repository ships the GNU General Public License v3.0 in [`LICENSE`](/home/benjamin/Repos/lfetch/LICENSE).
