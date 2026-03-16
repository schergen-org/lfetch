import Std

namespace Lfetch.Info.Shell

def fetch : IO (List String) := do
  match (← IO.getEnv "SHELL") with
  | some sh => pure [sh]
  | none    => pure ["unknown"]

end Lfetch.Info.Shell
