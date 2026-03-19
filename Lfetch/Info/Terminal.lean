import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Terminal

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "TERM") with
  | some t => pure [Lfetch.Info.textDoc t]
  | none =>
    match (← IO.getEnv "TERM_PROGRAM") with
    | some t => pure [Lfetch.Info.textDoc t]
    | none   => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Terminal
