import Std
import Lfetch.Info.Common

namespace Lfetch.Info.User

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "USER") with
  | some u => pure [Lfetch.Info.textDoc u]
  | none =>
    match (← IO.getEnv "LOGNAME") with
    | some u => pure [Lfetch.Info.textDoc u]
    | none   => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.User
