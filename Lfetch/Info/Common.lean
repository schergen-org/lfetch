import Lfetch.Config.Types
import leansi

namespace Lfetch.Info

open leansi
open leansi.Doc

abbrev InfoDoc := Doc Style
abbrev InfoLines := List InfoDoc

def textDoc (text : String) : InfoDoc :=
  Doc.text text

def textLine (text : String) : InfoLines :=
  [textDoc text]

def mutedDoc (colors : Colors) (text : String) : InfoDoc :=
  (Doc.text text).ann (Style.fg_hex colors.muted)

def mutedItalicDoc (colors : Colors) (text : String) : InfoDoc :=
  italic (mutedDoc colors text)

def unknownDoc (colors : Colors) : InfoDoc :=
  mutedItalicDoc colors "unknown"

private def accentColorLevel (colors : Colors) : ColorLevel :=
  (Style.fg_hex colors.accent).foreground.getD ColorLevel.none

def clampPercent (pct : Nat) : Fin 101 :=
  let clamped := min pct 100
  ⟨clamped, Nat.lt_succ_of_le (Nat.min_le_right pct 100)⟩

def accentProgressBar (colors : Colors) (pct : Nat) (width : Nat := 10) : InfoDoc :=
  progressBar
    { width := width
      thresholds := [{ upperBound := 100, color := accentColorLevel colors }]
      defaultColor := accentColorLevel colors
    }
    (clampPercent pct)

end Lfetch.Info
