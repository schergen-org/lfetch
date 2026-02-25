import Std

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

def fetch : IO String := do
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
      pure s!"{usedMiB} MiB used / {totalMiB} MiB (avail {availMiB} MiB)"
    | _, _ =>
      pure "unknown"
  else
    pure "unknown"

end Lfetch.Info.RAM
