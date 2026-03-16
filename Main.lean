import Lfetch
import leansi

open Lfetch
open leansi
open leansi.Doc

def main : IO Unit := do
  let cfg ← loadConfig
  Output.printConfig cfg
  println (Doc.text "1337" |> bright_red)
