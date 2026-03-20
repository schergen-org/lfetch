import Lfetch.Runtime.InfoRegistry
import Lfetch.Config.Types
import Lfetch.Info.Common

namespace Lfetch

/-- Fetches the rendered lines for each requested info key in order. -/
def fetchAll (colors : Colors) (keys : List InfoKey) : IO (List (InfoKey × Lfetch.Info.InfoLines)) := do
  keys.mapM (fun k => do
    let v ← Runtime.InfoRegistry.runInfo colors k
    pure (k, v)
  )

end Lfetch
