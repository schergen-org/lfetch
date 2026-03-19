import Lfetch.Domain.InfoKey

namespace Lfetch

open Lean

structure Colors where
  primary : String
  secondary : String
  accent : String
  muted : String
  tresholdLow: String
  tresholdMid: String
  tresholdHigh: String
  deriving Repr, Inhabited, FromJson, ToJson

structure InfoGroup where
  title : Option String := none
  padding : Option Nat := none
  infos : List InfoKey
  deriving Repr, Inhabited, FromJson, ToJson

structure Config where
  colors : Colors
  groups : List InfoGroup
  deriving Repr, Inhabited, FromJson, ToJson

def Config.infoKeys (cfg : Config) : List InfoKey :=
  cfg.groups.flatMap (fun group => group.infos)

end Lfetch
