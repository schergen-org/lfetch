import Lfetch.Config
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

namespace Lfetch

def runInfo : InfoKey → IO String
  | .dummy     => Info.Dummy.fetch
  | .os        => Info.OS.fetch
  | .drive     => Info.Drive.fetch
  | .user      => Info.User.fetch
  | .shell     => Info.Shell.fetch
  | .home      => Info.Home.fetch
  | .hostname  => Info.Host.fetch
  | .kernel    => Info.Kernel.fetch
  | .arch      => Info.Arch.fetch
  | .terminal   => Info.Terminal.fetch
  | .locale    => Info.Language.fetch
  | .uptime    => Info.Uptime.fetch
  | .cpu       => Info.CPU.fetch
  | .ram       => Info.RAM.fetch

def fetchAll (keys : List InfoKey) : IO (List (InfoKey × String)) := do
  keys.mapM (fun k => do
    let v ← runInfo k
    pure (k, v)
  )

end Lfetch
