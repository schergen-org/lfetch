import Std

namespace Lfetch.Info.Arch

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

def fetch : IO (List String) := do
  try
    let out ← IO.Process.output { cmd := "uname", args := #["-m"] }
    if out.exitCode = 0 then
      let a := trimLine out.stdout
      pure [if a = "" then "unknown" else a]
    else
      pure ["unknown"]
  catch _ =>
    pure ["unknown"]

end Lfetch.Info.Arch
