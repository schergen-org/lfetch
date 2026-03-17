import Std
import Lfetch.Info.Common

namespace Lfetch.Info.CPU

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def parseKeyValue (line : String) : Option (String × String) := do
  -- "key : value"
  let parts := line.splitOn ":"
  if parts.length < 2 then
    none
  else
    let key := trimLine (parts.getD 0 "")
    let val := trimLine (String.intercalate ":" (parts.drop 1))
    some (key, val)

private def findFirstValue (content : String) (wanted : List String) : Option String :=
  let lines := content.splitOn "\n" |>.map trimLine
  let rec go : List String → Option String
    | [] => none
    | l :: ls =>
      match parseKeyValue l with
      | some (k, v) =>
        if wanted.any (fun w => w = k) then
          if v = "" then go ls else some v
        else
          go ls
      | none => go ls
  go lines

def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  let path : System.FilePath := "/proc/cpuinfo"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    match findFirstValue content ["model name", "Hardware", "Processor"] with
    | some cpu => pure [Lfetch.Info.textDoc cpu]
    | none     => pure [Lfetch.Info.unknownDoc colors]
  else
    pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.CPU
