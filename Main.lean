import Lfetch

open Lfetch

def main : IO Unit := do
  let cfg ← loadConfig
  let results ← fetchAll cfg.infoKeys
  -- Darstellung kommt später; aktuell nur Debug-Ausgabe:
  for (k, v) in results do
    IO.println s!"{k.toString}: {v}"
