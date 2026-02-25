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

/-- small bar visualisation like `[████░░░░░░] 42%`. -/
private def usageBar (pctStr : String) (barWidth : Nat := 10) : String :=
  let pctClean := pctStr.replace "%" "" |> trimLine
  let pct := pctClean.toNat?.getD 0
  let filled := (pct * barWidth + 50) / 100   -- rounded
  let empty  := barWidth - filled
  let bar := String.ofList (List.replicate filled '█') ++
             String.ofList (List.replicate empty  '░')
  s!"[{bar}] {pctStr}"

private def formatEntry (e : DriveEntry) : String :=
  let bar := usageBar e.usePct
  s!"  {e.mountPoint}  {bar}  {e.used}/{e.size}"

private def isRealFs (e : DriveEntry) : Bool :=
  let startsReal := e.filesystem.startsWith "/" || e.filesystem.startsWith "//"
  let notExcluded := !(excludedFsTypes.any (· == e.filesystem))
  startsReal && notExcluded

def fetch : IO String := do
  let result ← IO.Process.output {
    cmd  := "df"
    args := #["-h"]
  }
  if result.exitCode != 0 then
    return "error running df"
  let lines := result.stdout.splitOn "\n"
    |>.map trimLine
    |>.filter (· ≠ "")

  let dataLines := lines.drop 1
  let entries := dataLines.filterMap parseDfLine
  let realEntries := entries.filter isRealFs
  if realEntries.isEmpty then
    return "no drives found"
  let formatted := realEntries.map formatEntry
  return "\n" ++ String.intercalate "\n" formatted

end Lfetch.Info.Drive
