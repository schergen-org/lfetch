import Lfetch.Runtime.InfoRegistry

namespace Lfetch

def fetchAll (keys : List InfoKey) : IO (List (InfoKey × List String)) := do
  keys.mapM (fun k => do
    let v ← Runtime.InfoRegistry.runInfo k
    pure (k, v)
  )

end Lfetch
