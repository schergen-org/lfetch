import Lfetch.Config.Types

namespace Lfetch

def defaultColors : Colors :=
  {
    primary := "#FFFFFF"
    secondary := "#C0C0C0"
    accent := "#4FA3FF"
    muted := "#808080"
    tresholdLow := "#4FA3FF"
    tresholdMid := "#FFA500"
    tresholdHigh := "#FF0000"
  }

def defaultConfig : Config :=
  {
    colors := defaultColors
    groups := [
      {
        title := none
        infos := [.user, .hostname, .os]
      }
    ]
  }

end Lfetch
