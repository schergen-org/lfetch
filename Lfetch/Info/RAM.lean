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

private def kibToMiB (kib : Nat) : Nat :=
  kib / 1024

private def usagePercent (used total : Nat) : Nat :=
  if total = 0 then 0 else (used * 100) / total

private def formatUsage (colors : Lfetch.Colors) (usedMiB totalMiB availMiB : Nat) : Lfetch.Info.InfoDoc :=
  let bar := Lfetch.Info.accentProgressBar colors (usagePercent usedMiB totalMiB)
  let details := Lfetch.Info.mutedDoc colors s!"{usedMiB} MiB used / {totalMiB} MiB (avail {availMiB} MiB)"
  bar ++ Lfetch.Info.textDoc "  " ++ details

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  let path : System.FilePath := "/proc/meminfo"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    let total? := parseMeminfoKiB content "MemTotal"
    let avail? := parseMeminfoKiB content "MemAvailable"
    match total?, avail? with
    | some totalKiB, some availKiB =>
      let usedKiB := totalKiB - availKiB
      let totalMiB := kibToMiB totalKiB
      let usedMiB  := kibToMiB usedKiB
      let availMiB := kibToMiB availKiB
      pure [formatUsage colors usedMiB totalMiB availMiB]
    | _, _ =>
      pure [Lfetch.Info.unknownDoc colors]
  else
    pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.RAM
