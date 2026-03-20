import Lfetch.Info.Common
import leansi.Doc.Type

namespace Lfetch.Info.Drive

private def excludedFsTypes : List String :=
  ["tmpfs", "devtmpfs", "squashfs", "overlay", "efivarfs", "devpts",
   "sysfs", "proc", "securityfs", "cgroup", "cgroup2", "pstore",
   "bpf", "tracefs", "debugfs", "hugetlbfs", "mqueue", "configfs",
   "fusectl", "ramfs", "nsfs", "fuse.portal", "fuse.gvfsd-fuse"]

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

structure DriveEntry where
  filesystem : String
  size       : String
  used       : String
  avail      : String
  usePct     : String
  mountPoint : String
  deriving Repr

/-- Parses a `df -h` output line into a structured drive entry. -/
private def parseDfLine (line : String) : Option DriveEntry :=
  let parts := line.splitOn " " |>.filter (· ≠ "")
  match parts with
  | fs :: size :: used :: avail :: pct :: mount =>
    let mountStr := String.intercalate " " mount
    some {
      filesystem := fs
      size       := size
      used       := used
      avail      := avail
      usePct     := pct
      mountPoint := mountStr
    }
  | _ => none

private def parsePct (pctStr : String) : Nat :=
  ((pctStr.replace "%" "").trimAscii.toString).toNat?.getD 0

private def formatEntry (colors : Lfetch.Colors) (e : DriveEntry) : Lfetch.Info.InfoLines :=
  let bar := Lfetch.Info.ProgressBarWithThresholds colors (parsePct e.usePct) true 20
  let details := Lfetch.Info.mutedDoc colors s!"{e.used}/{e.size}"
  [Lfetch.Info.textDoc e.mountPoint, details, bar]

private def isRealFs (e : DriveEntry) : Bool :=
  let startsReal := e.filesystem.startsWith "/" || e.filesystem.startsWith "//"
  let notExcluded := !(excludedFsTypes.any (· == e.filesystem))
  startsReal && notExcluded

/-- Lists real mounted filesystems and renders each one with usage details and a bar. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  try
    let result ← IO.Process.output {
      cmd  := "df"
      args := #["-h"]
    }

    if result.exitCode != 0 then
      return [Lfetch.Info.mutedItalicDoc colors "error running df"]

    let lines :=
      result.stdout.splitOn "\n"
      |>.map trimLine
      |>.filter (· ≠ "")

    let dataLines := lines.drop 1
    let entries := dataLines.filterMap parseDfLine
    let realEntries := entries.filter isRealFs

    if realEntries.isEmpty then
      return [Lfetch.Info.mutedItalicDoc colors "no drives found"]

    let formatted : Lfetch.Info.InfoLines :=
      (realEntries.map (formatEntry colors)).foldr
        (fun docs acc =>
          if acc.isEmpty then
            docs
          else
            docs ++ [leansi.Doc.empty] ++ acc)
        []

    return formatted

  catch _ =>
    return [Lfetch.Info.mutedItalicDoc colors "error running df"]

end Lfetch.Info.Drive
