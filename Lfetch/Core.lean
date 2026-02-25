import Lfetch.Config
import Lfetch.Info.Dummy
import Lfetch.Info.OS
import Lfetch.Info.User
import Lfetch.Info.Shell
import Lfetch.Info.Home
import Lfetch.Info.Hostname

namespace Lfetch

def runInfo : InfoKey → IO String
  | .dummy     => Info.Dummy.fetch
  | .os        => Info.OS.fetch
  | .user      => Info.User.fetch
  | .shell     => Info.Shell.fetch
  | .home      => Info.Home.fetch
  | .hostname  => Info.Host.fetch

def fetchAll (keys : List InfoKey) : IO (List (InfoKey × String)) := do
  keys.mapM (fun k => do
    let v ← runInfo k
    pure (k, v)
  )

end Lfetch
