import Lfetch.Config.Types

namespace Lfetch

def defaultColors : Colors :=
  {
    primary := "#94e2d5"
    secondary := "#fab387"
    accent := "#89b4fa"
    muted := "#585b70"
    tresholdLow := "#a6e3a1"
    tresholdMid := "#f9e2af"
    tresholdHigh := "#f38ba8"
  }

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
