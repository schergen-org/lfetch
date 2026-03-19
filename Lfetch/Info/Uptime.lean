import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Uptime

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def parseUptimeSeconds (content : String) : Option Nat := do
  -- Format: "<seconds>.<fraction> <idle>.<fraction>\n"
  let firstField? := content.splitOn " " |>.head?
  let firstField := trimLine (firstField?.getD "")
  let secsStr := (firstField.splitOn "." |>.getD 0 "")
  secsStr.toNat?

private def fmtUptime (secs : Nat) : String :=
  let minutes := secs / 60
  let hours   := minutes / 60
  let days    := hours / 24
  let h       := hours % 24
  let m       := minutes % 60
  if days > 0 then
    s!"{days}d {h}h {m}m"
  else if hours > 0 then
    s!"{h}h {m}m"
  else
    s!"{m}m"

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  let path : System.FilePath := "/proc/uptime"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    match parseUptimeSeconds content with
    | some s => pure [Lfetch.Info.textDoc (fmtUptime s)]
    | none   => pure [Lfetch.Info.unknownDoc colors]
  else
    pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Uptime
