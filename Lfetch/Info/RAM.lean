import Std
import Lfetch.Info.Common

namespace Lfetch.Info.RAM

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def parseMeminfoKiB (content : String) (keyWanted : String) : Option Nat :=
  let lines := content.splitOn "\n" |>.map trimLine
  let rec go : List String → Option Nat
    | [] => none
    | l :: ls =>
      -- e.g. "MemTotal:       16333636 kB"
      if l.startsWith (keyWanted ++ ":") then
        let afterColon := (l.splitOn ":" |>.drop 1)
        let rest := trimLine (String.intercalate ":" afterColon)
        let toks := rest.splitOn " " |>.map trimLine |>.filter (· ≠ "")
        match toks with
        | nStr :: _ =>
          nStr.toNat?
        | _ => none
      else
        go ls
  go lines

private def kibToGiB (kib : Nat) : Float :=
  kib.toFloat / 1024 / 1024

private def usagePercent (used total : Float) : Nat :=
  if total == 0.0 then
    0
  else
    ((used * 100.0) / total).round.toUInt64.toNat

def format2 (x : Float) : String :=
  let scaled := Float.round (x * 100.0)
  let intPart := (scaled / 100.0).toUInt64.toNat
  let fracPart := (scaled.toUInt64.toNat) % 100
  s!"{intPart}.{if fracPart < 10 then "0" else ""}{fracPart}"

private def formatUsage (colors : Lfetch.Colors) (usedMiB totalMiB : Float) : Lfetch.Info.InfoLines :=
  let bar := Lfetch.Info.ProgressBarWithTresholds colors (usagePercent usedMiB totalMiB) true 20
  let details := Lfetch.Info.mutedDoc colors s!"{format2 usedMiB} GiB / {format2 totalMiB} GiB"
  [details, bar]

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  let path : System.FilePath := "/proc/meminfo"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    let total? := parseMeminfoKiB content "MemTotal"
    let avail? := parseMeminfoKiB content "MemAvailable"
    match total?, avail? with
    | some totalKiB, some availKiB =>
      let usedKiB := totalKiB - availKiB
      let totalGiB := kibToGiB totalKiB
      let usedGiB  := kibToGiB usedKiB
      pure (formatUsage colors usedGiB totalGiB)
    | _, _ =>
      pure [Lfetch.Info.unknownDoc colors]
  else
    pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.RAM
