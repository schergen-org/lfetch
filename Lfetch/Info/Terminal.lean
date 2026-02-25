import Std

namespace Lfetch.Info.Terminal

def fetch : IO String := do
  match (← IO.getEnv "TERM") with
  | some t => pure t
  | none =>
    match (← IO.getEnv "TERM_PROGRAM") with
    | some t => pure t
    | none   => pure "unknown"

end Lfetch.Info.Terminal
