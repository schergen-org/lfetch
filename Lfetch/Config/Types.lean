import Lfetch.Domain.InfoKey

namespace Lfetch

open Lean

structure Colors where
  primary : String
  secondary : String
  accent : String
  muted : String
  thresholdLow: String
  thresholdMid: String
  thresholdHigh: String
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

/-- Collects all configured info keys in the order they should be rendered. -/
def Config.infoKeys (cfg : Config) : List InfoKey :=
  cfg.groups.flatMap (fun group => group.infos)

end Lfetch
