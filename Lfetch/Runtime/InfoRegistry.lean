import Lfetch.Domain.InfoKey
import Lfetch.Config.Types
import Lfetch.Info.Common
import Lfetch.Info.Dummy
import Lfetch.Info.OS
import Lfetch.Info.Drive
import Lfetch.Info.User
import Lfetch.Info.Shell
import Lfetch.Info.Home
import Lfetch.Info.Hostname
import Lfetch.Info.Kernel
import Lfetch.Info.Arch
import Lfetch.Info.Terminal
import Lfetch.Info.Locale
import Lfetch.Info.Uptime
import Lfetch.Info.CPU
import Lfetch.Info.RAM
import Lfetch.Info.Battery

namespace Lfetch.Runtime.InfoRegistry

def runInfo (colors : Lfetch.Colors) : Lfetch.InfoKey → IO Lfetch.Info.InfoLines
  | .dummy => Lfetch.Info.Dummy.fetch colors
  | .os => Lfetch.Info.OS.fetch colors
  | .drive => Lfetch.Info.Drive.fetch colors
  | .user => Lfetch.Info.User.fetch colors
  | .shell => Lfetch.Info.Shell.fetch colors
  | .home => Lfetch.Info.Home.fetch colors
  | .hostname => Lfetch.Info.Host.fetch colors
  | .kernel => Lfetch.Info.Kernel.fetch colors
  | .arch => Lfetch.Info.Arch.fetch colors
  | .terminal => Lfetch.Info.Terminal.fetch colors
  | .locale => Lfetch.Info.Language.fetch colors
  | .uptime => Lfetch.Info.Uptime.fetch colors
  | .cpu => Lfetch.Info.CPU.fetch colors
  | .ram => Lfetch.Info.RAM.fetch colors
  | .battery => Lfetch.Info.Battery.fetch colors

end Lfetch.Runtime.InfoRegistry
