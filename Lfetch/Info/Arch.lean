import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Arch

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  try
    let out ← IO.Process.output { cmd := "uname", args := #["-m"] }
    if out.exitCode = 0 then
      let a := trimLine out.stdout
      pure [if a = "" then Lfetch.Info.unknownDoc colors else Lfetch.Info.textDoc a]
    else
      pure [Lfetch.Info.unknownDoc colors]
  catch _ =>
    pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Arch
