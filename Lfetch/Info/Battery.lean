import Lfetch.Info.Common

namespace Lfetch.Info.Battery

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def readBatteryCapacity (batPath : System.FilePath) : IO (Option Nat) := do
  let capFile := batPath / "capacity"
  if !(← capFile.pathExists) then return none
  let raw ← IO.FS.readFile capFile
  return (trimLine raw).toNat?

private def readBatteryStatus (batPath : System.FilePath) : IO String := do
  let statusFile := batPath / "status"
  if !(← statusFile.pathExists) then return "Unknown"
  let raw ← IO.FS.readFile statusFile
  return trimLine raw

private def statusIcon (status : String) : String :=
  match status.toLower with
  | "charging"     => "Charging"
  | "discharging"  => "Discharging"
  | "full"         => "Full"
  | "not charging" => "Not charging"
  | _              => status

private def findBatteries : IO (List System.FilePath) := do
  let base : System.FilePath := "/sys/class/power_supply"
  if !(← base.pathExists) then return []
  let entries ← base.readDir
  let bats := entries.toList.filter (fun e => e.fileName.startsWith "BAT")
  let sorted := bats.map (·.path) |>.mergeSort (fun a b => a.toString < b.toString)
  return sorted

private def formatEntry (colors : Lfetch.Colors) (name : String) (pct : Nat) (status : String) : Lfetch.Info.InfoDoc :=
  let bar := Lfetch.Info.ProgressBarWithTresholds colors pct false
  let state := Lfetch.Info.mutedDoc colors (statusIcon status)
  Lfetch.Info.textDoc name ++ Lfetch.Info.textDoc "  " ++ bar ++ Lfetch.Info.textDoc "  " ++ state

private def formatUnknownEntry (colors : Lfetch.Colors) (name : String) : Lfetch.Info.InfoDoc :=
  Lfetch.Info.textDoc name ++ Lfetch.Info.textDoc "  " ++ Lfetch.Info.mutedItalicDoc colors "unknown"

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  let batteries ← findBatteries
  if batteries.isEmpty then
    return [Lfetch.Info.mutedItalicDoc colors "No battery found"]
  let mut lines : Lfetch.Info.InfoLines := []
  for bat in batteries do
    let name := bat.fileName.getD "BAT?"
    let cap ← readBatteryCapacity bat
    let status ← readBatteryStatus bat
    match cap with
    | some pct =>
      lines := lines ++ [formatEntry colors name pct status]
    | none =>
      lines := lines ++ [formatUnknownEntry colors name]
  return lines

end Lfetch.Info.Battery
