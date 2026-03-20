import Lfetch.Config.Types

namespace Lfetch

/-- Provides the built-in color palette used when no config file is available. -/
def defaultColors : Colors :=
  {
    primary := "#94e2d5"
    secondary := "#fab387"
    accent := "#89b4fa"
    muted := "#585b70"
    thresholdLow := "#a6e3a1"
    thresholdMid := "#f9e2af"
    thresholdHigh := "#f38ba8"
  }

/-- Defines the fallback layout and info groups for a default `lfetch` report. -/
def defaultConfig : Config :=
  {
    colors := defaultColors
    groups := [
      {
        title := "Overview"
        infos := [.user, .os, .kernel, .uptime, .shell, .cpu, .arch, .palette]
      },
      {
        title := "Resources"
        padding := some 1
        infos := [.ram, .battery, .drive]
      }
    ]
  }

end Lfetch
