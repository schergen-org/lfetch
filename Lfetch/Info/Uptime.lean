import Std

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

def fetch : IO (List String) := do
  let path : System.FilePath := "/proc/uptime"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    match parseUptimeSeconds content with
    | some s => pure [fmtUptime s]
    | none   => pure ["unknown"]
  else
    pure ["unknown"]

end Lfetch.Info.Uptime
