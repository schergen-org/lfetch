import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Shell

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "SHELL") with
  | some sh => pure [Lfetch.Info.textDoc sh]
  | none    => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Shell
