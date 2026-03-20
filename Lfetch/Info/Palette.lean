import Lfetch.Info.Common
import leansi

namespace Lfetch.Info.Palette

open leansi
open leansi.Doc

private def swatch (paint : Lfetch.Info.InfoDoc → Lfetch.Info.InfoDoc) : Lfetch.Info.InfoDoc :=
  Doc.text "   " |> paint

/-- Renders the standard and bright terminal color palettes as two rows of swatches. -/
def fetch (_colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  let standard :=
    Layout.hcatSep 0
      [ swatch bg_black
      , swatch bg_red
      , swatch bg_green
      , swatch bg_yellow
      , swatch bg_blue
      , swatch bg_magenta
      , swatch bg_cyan
      , swatch bg_white
      ]
  let bright :=
    Layout.hcatSep 0
      [ swatch bg_bright_black
      , swatch bg_bright_red
      , swatch bg_bright_green
      , swatch bg_bright_yellow
      , swatch bg_bright_blue
      , swatch bg_bright_magenta
      , swatch bg_bright_cyan
      , swatch bg_bright_white
      ]
  pure [standard, bright]

end Lfetch.Info.Palette
