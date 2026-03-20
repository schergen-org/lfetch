import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Home

/-- Reports the user's home directory from the environment. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "HOME") with
  | some h => pure [Lfetch.Info.textDoc h]
  | none   => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Home
