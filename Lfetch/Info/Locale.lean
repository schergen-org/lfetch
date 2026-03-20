import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Language

/-- Reports the active locale from `LANG` or `LC_ALL`. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "LANG") with
  | some l => pure [Lfetch.Info.textDoc l]
  | none =>
    match (← IO.getEnv "LC_ALL") with
    | some l => pure [Lfetch.Info.textDoc l]
    | none   => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Language
