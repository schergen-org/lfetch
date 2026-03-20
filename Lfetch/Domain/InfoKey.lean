import Lean.Data.Json

namespace Lfetch

open Lean

inductive InfoKey
  | dummy
  | palette
  | os
  | drive
  | user
  | shell
  | home
  | hostname
  | kernel
  | arch
  | terminal
  | locale
  | uptime
  | cpu
  | ram
  | battery
  deriving Repr, DecidableEq

/-- Converts an `InfoKey` to the lowercase config string used in JSON. -/
def InfoKey.toString : InfoKey → String
  | .dummy => "dummy"
  | .palette => "palette"
  | .os => "os"
  | .drive => "drive"
  | .user => "user"
  | .shell => "shell"
  | .home => "home"
  | .hostname => "hostname"
  | .kernel => "kernel"
  | .arch => "arch"
  | .terminal => "terminal"
  | .locale => "locale"
  | .uptime => "uptime"
  | .cpu => "cpu"
  | .ram => "ram"
  | .battery => "battery"

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

/-- Parses a config string into the corresponding info provider key. -/
def InfoKey.parse (s : String) : Option InfoKey :=
  match (trimLine s).toLower with
  | "dummy" => some .dummy
  | "palette" => some .palette
  | "os" => some .os
  | "drive" => some .drive
  | "user" => some .user
  | "shell" => some .shell
  | "home" => some .home
  | "hostname" => some .hostname
  | "kernel" => some .kernel
  | "arch" => some .arch
  | "terminal" => some .terminal
  | "locale" => some .locale
  | "uptime" => some .uptime
  | "cpu" => some .cpu
  | "ram" => some .ram
  | "battery" => some .battery
  | _ => none

instance : FromJson InfoKey where
  fromJson?
    | .str s =>
      match InfoKey.parse s with
      | some infoKey => pure infoKey
      | none => throw s!"invalid info key: {s}"
    | json => throw s!"expected info key string, got: {json.compress}"

instance : ToJson InfoKey where
  toJson infoKey := Json.str infoKey.toString

end Lfetch
