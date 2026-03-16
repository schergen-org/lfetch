import Lfetch

open Lfetch

def main : IO Unit := do
  let cfg ← loadConfig
  Output.printConfig cfg
