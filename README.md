[![Lean Action CI](https://github.com/schergen-org/lfetch/actions/workflows/lean_action_ci.yml/badge.svg)](https://github.com/schergen-org/lfetch/actions/workflows/lean_action_ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
<a href="https://github.com/schergen-org/lfetch/releases/tag/v1.0.0" alt="Version 1.0.0">
        <img src="https://img.shields.io/badge/version-1.0.0-green" /></a>
        
<p align="center">This program serves as a sample implementation using <a href="https://github.com/schergen-org/Leansi">Leansi</a></p>

> [!NOTE]  
> This programm was created as part of the “Funktionale Programmierung in Lean” module as an examination requirement at the University of Applied Sciences Mittelhessen.

<h1 align="center">lfetch</h1>
<p align="center">A simple system information tool written in LEAN 4</p><br>
<sup><p align="center">Functionally inspired by <a href="https://github.com/dylanaraps/pfetch">pfetch</a>, <a href="https://github.com/dylanaraps/neofetch">neofetch</a>, ...</p></sup><br>

<img width="600" alt="Lfetch" src="https://github.com/user-attachments/assets/32eaaff2-a52e-445d-b175-afe110605a42" align="right" />

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

`lfetch` is a small “fetch”-style system information tool, similar in spirit to **neofetch**, but written in **Lean 4**. It prints a set of basic system details in the terminal.

What gets printed (and in what order) is controlled through a simple config file.


<br>
<br>
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


## Installation via Debian Package

`lfetch` can be installed as a `.deb` package on Debian-based Linux distributions:

### Oneliner 
```bash
wget https://github.com/schergen-org/lfetch/releases/download/v1.0.0/lfetch_1.0.0_amd64.deb \
&& sudo dpkg -i ./lfetch_1.0.0_amd64.deb \
&& rm lfetch_1.0.0_amd64.deb
```

1. **Download the latest release:**

   Visit the [releases page](https://github.com/schergen-org/lfetch/releases) and download the `.deb` package for your architecture.

2. **Install the package:**

   ```bash
   sudo dpkg -i lfetch_*.deb
   ```

   Or use your preferred package manager (e.g., `apt`):

   ```bash
   sudo apt install ./lfetch_*.deb
   ```

3. **Verify the installation:**

   ```bash
   lfetch
   ```

4. **Configuration:**

   `lfetch` will automatically create a default configuration file at `$HOME/.config/lfetch/config.json` on first run if no custom configuration exists. You can edit this file to customize colors and displayed information.


## Build And Run

The repository is configured for:

- Lean toolchain `leanprover/lean4:v4.28.0`
- package version `1.0.0`
- executable target `lfetch`
- library target `Lfetch`

Build from source with Lake:

```bash
lake build
lake exe lfetch
```

Repository-backed note about dependencies:

- `leansi` is currently required via the SSH URL `git@github.com:schergen-org/Leansi.git` in [`lakefile.toml`](/lakefile.toml). On a fresh machine, fetching dependencies therefore requires GitHub SSH access or a local change to that dependency URL.

## Configuration

`lfetch` reads:

```text
$HOME/.config/lfetch/config.json
```

Load behavior in the current code:

- if the file does not exist, `lfetch` silently uses the built-in default config
- if JSON parsing fails, `lfetch` falls back to the default config and renders a warning box

### Color Fields

The configured colors are used as follows:

- `primary`: box borders, group titles and parts of the ASCII logo
- `secondary`: info labels and parts of the ASCII logo
- `accent`: warning box title/border and parts of the ASCII logo
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

The built-in default config from [`Lfetch/Config/Defaults.lean`](/Lfetch/Config/Defaults.lean) is:

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

The currently supported keys are defined in [`Lfetch/Domain/InfoKey.lean`](/Lfetch/Domain/InfoKey.lean).

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

- [`Lfetch/Config`](/Lfetch/Config) contains config types, defaults, and loading
- [`Lfetch/Domain`](/Lfetch/Domain) contains domain types such as `InfoKey`
- [`Lfetch/Runtime`](/Lfetch/Runtime) maps keys to provider modules
- [`Lfetch/Info`](/Lfetch/Info) contains the individual info providers
- [`Lfetch/Output`](/Lfetch/Output) contains report rendering

## License

This repository ships the GNU General Public License v3.0 in [`LICENSE`](/LICENSE).
