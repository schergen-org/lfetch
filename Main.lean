import Lfetch
import leansi

open Lfetch

def main : IO Unit := do
  let (cfg, warnings) ← loadConfigWithWarnings
  Output.printReport cfg warnings
