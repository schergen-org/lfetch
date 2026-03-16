import Lfetch.Domain.InfoKey
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

def runInfo : Lfetch.InfoKey → IO (List String)
  | .dummy => Lfetch.Info.Dummy.fetch
  | .os => Lfetch.Info.OS.fetch
  | .drive => Lfetch.Info.Drive.fetch
  | .user => Lfetch.Info.User.fetch
  | .shell => Lfetch.Info.Shell.fetch
  | .home => Lfetch.Info.Home.fetch
  | .hostname => Lfetch.Info.Host.fetch
  | .kernel => Lfetch.Info.Kernel.fetch
  | .arch => Lfetch.Info.Arch.fetch
  | .terminal => Lfetch.Info.Terminal.fetch
  | .locale => Lfetch.Info.Language.fetch
  | .uptime => Lfetch.Info.Uptime.fetch
  | .cpu => Lfetch.Info.CPU.fetch
  | .ram => Lfetch.Info.RAM.fetch
  | .battery => Lfetch.Info.Battery.fetch

end Lfetch.Runtime.InfoRegistry
