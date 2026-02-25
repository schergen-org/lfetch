import Std

namespace Lfetch.Info.Home

def fetch : IO String := do
  match (← IO.getEnv "HOME") with
  | some h => pure h
  | none   => pure "unknown"

end Lfetch.Info.Home
