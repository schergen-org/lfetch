import Lfetch.Core
import Lfetch.Config.Types

namespace Lfetch.Output

private def printInfoLines (k : InfoKey) (lines : List String) : IO Unit := do
  match lines with
  | [] => IO.println s!"{k.toString}: unknown"
  | first :: rest => do
      IO.println s!"{k.toString}: {first}"
      for line in rest do
        IO.println s!"  {line}"

private def printGroup (group : InfoGroup) : IO Unit := do
  match group.title with
  | some title => IO.println title
  | none => pure ()
  let results ← fetchAll group.infos
  for (k, lines) in results do
    printInfoLines k lines

private partial def printGroups : List InfoGroup → IO Unit
  | [] => pure ()
  | [group] => printGroup group
  | group :: rest => do
      printGroup group
      IO.println ""
      printGroups rest

def printConfig (cfg : Config) : IO Unit := do
  printGroups cfg.groups

end Lfetch.Output
