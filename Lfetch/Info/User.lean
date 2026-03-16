import Std

namespace Lfetch.Info.User

def fetch : IO (List String) := do
  match (← IO.getEnv "USER") with
  | some u => pure [u]
  | none =>
    match (← IO.getEnv "LOGNAME") with
    | some u => pure [u]
    | none   => pure ["unknown"]

end Lfetch.Info.User
