import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Shell

/-- Reports the shell path from the current process environment. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "SHELL") with
  | some sh =>
    let name := sh.takeEndWhile (fun c => c != '/') |> toString
    pure [Lfetch.Info.textDoc name]
  | none    => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Shell
