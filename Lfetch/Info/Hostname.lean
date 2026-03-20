import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Host

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def readEtcHostname : IO (Option String) := do
  let path : System.FilePath := "/etc/hostname"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    match content.splitOn "\n" with
    | [] => pure none
    | line :: _ =>
      let hn := trimLine line
      if hn = "" then pure none else pure (some hn)
  else
    pure none

private def unameFallback : IO (Option String) := do
  try
    let out ← IO.Process.output { cmd := "uname", args := #["-n"] }
    if out.exitCode = 0 then
      let hn := trimLine out.stdout
      if hn = "" then pure none else pure (some hn)
    else
      pure none
  catch _ =>
    pure none

/-- Resolves the hostname from `/etc/hostname` with `uname -n` as fallback. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← readEtcHostname) with
  | some hn => pure [Lfetch.Info.textDoc hn]
  | none =>
    match (← unameFallback) with
    | some hn => pure [Lfetch.Info.textDoc hn]
    | none    => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Host
