import Std

namespace Lfetch.Info.Language

def fetch : IO String := do
  match (← IO.getEnv "LANG") with
  | some l => pure l
  | none =>
    match (← IO.getEnv "LC_ALL") with
    | some l => pure l
    | none   => pure "unknown"

end Lfetch.Info.Language
