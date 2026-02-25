import Lfetch.Config
import Lfetch.Info.Dummy
import Lfetch.Info.OS
import Lfetch.Info.User

namespace Lfetch

def runInfo : InfoKey → IO String
  | .dummy     => Info.Dummy.fetch
  | .os        => Info.OS.fetch
  | .user      => Info.User.fetch

def fetchAll (keys : List InfoKey) : IO (List (InfoKey × String)) := do
  keys.mapM (fun k => do
    let v ← runInfo k
    pure (k, v)
  )

end Lfetch
