namespace Lfetch.Info.Battery

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def batteryBar (pct : Nat) (barWidth : Nat := 10) : String :=
  let clamped := min pct 100
  let filled := (clamped * barWidth + 50) / 100
  let empty  := barWidth - filled
  let bar := String.ofList (List.replicate filled '█') ++
             String.ofList (List.replicate empty  '░')
  s!"[{bar}] {clamped}%"

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
  | "charging"     => "⚡ Charging"
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

def fetch : IO String := do
  let batteries ← findBatteries
  if batteries.isEmpty then
    return "No battery found"
  let mut lines : List String := []
  for bat in batteries do
    let name := bat.fileName.getD "BAT?"
    let cap ← readBatteryCapacity bat
    let status ← readBatteryStatus bat
    match cap with
    | some pct =>
      let bar := batteryBar pct
      let icon := statusIcon status
      lines := lines ++ [s!"  {name}  {bar}  {icon}"]
    | none =>
      lines := lines ++ [s!"  {name}  unknown"]
  if lines.length == 1 then
    return (lines.head!).trimAsciiStart.toString
  return "\n" ++ String.intercalate "\n" lines

end Lfetch.Info.Battery
