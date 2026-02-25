import Lfetch.Config
import Lfetch.Info.Dummy
import Lfetch.Info.OS

namespace Lfetch

def runInfo : InfoKey → IO String
  | .dummy     => Info.Dummy.fetch
  | .os        => Info.OS.fetch

def fetchAll (keys : List InfoKey) : IO (List (InfoKey × String)) := do
  keys.mapM (fun k => do
    let v ← runInfo k
    pure (k, v)
  )

end Lfetch
