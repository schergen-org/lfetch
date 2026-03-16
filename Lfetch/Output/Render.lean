import Lfetch.Core
import Lfetch.Config.Types

namespace Lfetch.Output

private def printGroup (group : InfoGroup) : IO Unit := do
  match group.title with
  | some title => IO.println title
  | none => pure ()
  let results ← fetchAll group.infos
  for (k, v) in results do
    IO.println s!"{k.toString} \t: {v}"

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
