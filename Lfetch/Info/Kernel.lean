import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Kernel

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  try
    let out ← IO.Process.output { cmd := "uname", args := #["-sr"] }
    if out.exitCode = 0 then
      let k := trimLine out.stdout
      pure [if k = "" then Lfetch.Info.unknownDoc colors else Lfetch.Info.textDoc k]
    else
      pure [Lfetch.Info.unknownDoc colors]
  catch _ =>
    pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Kernel
