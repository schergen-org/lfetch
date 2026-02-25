import Std

namespace Lfetch.Info.Kernel

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

def fetch : IO String := do
  try
    let out ← IO.Process.output { cmd := "uname", args := #["-sr"] }
    if out.exitCode = 0 then
      let k := trimLine out.stdout
      pure (if k = "" then "unknown" else k)
    else
      pure "unknown"
  catch _ =>
    pure "unknown"

end Lfetch.Info.Kernel
