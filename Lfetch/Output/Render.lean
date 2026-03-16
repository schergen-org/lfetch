import Lfetch.Core
import Lfetch.Config.Types
import leansi

namespace Lfetch.Output

open leansi
open leansi.Doc

private structure Palette where
  primary : Style
  secondary : Style
  accent : Style
  muted : Style

private def hexDigitValue? (c : Char) : Option Nat :=
  if '0' ≤ c && c ≤ '9' then
    some (c.toNat - '0'.toNat)
  else if 'a' ≤ c && c ≤ 'f' then
    some (10 + (c.toNat - 'a'.toNat))
  else if 'A' ≤ c && c ≤ 'F' then
    some (10 + (c.toNat - 'A'.toNat))
  else
    none

private def hexByteValue? (hi lo : Char) : Option Nat := do
  let hi ← hexDigitValue? hi
  let lo ← hexDigitValue? lo
  pure (hi * 16 + lo)

private def parseHexColor? (hex : String) : Option (Nat × Nat × Nat) :=
  let normalized :=
    if hex.startsWith "#" then
      (hex.drop 1).toString
    else
      hex
  match normalized.toList with
  | [r1, r2, g1, g2, b1, b2] => do
      let r ← hexByteValue? r1 r2
      let g ← hexByteValue? g1 g2
      let b ← hexByteValue? b1 b2
      pure (r, g, b)
  | _ => none

private def styleFromHex (hex : String) (fallback : Style) : Style :=
  match parseHexColor? hex with
  | some (r, g, b) => Style.fg_rgb r g b
  | none => fallback

private def paletteOfConfig (cfg : Config) : Palette :=
  {
    primary := styleFromHex cfg.colors.primary Style.bright_white
    secondary := styleFromHex cfg.colors.secondary Style.bright_black
    accent := styleFromHex cfg.colors.accent Style.bright_cyan
    muted := styleFromHex cfg.colors.muted Style.grey
  }

private def infoLabel : InfoKey → String
  | .dummy => "Dummy"
  | .os => "OS"
  | .drive => "Drive"
  | .user => "User"
  | .shell => "Shell"
  | .home => "Home"
  | .hostname => "Hostname"
  | .kernel => "Kernel"
  | .arch => "Arch"
  | .terminal => "Terminal"
  | .locale => "Locale"
  | .uptime => "Uptime"
  | .cpu => "CPU"
  | .ram => "RAM"
  | .battery => "Battery"

private def valueLineDoc (palette : Palette) (line : String) : Doc Style :=
  let trimmed := line.trimAscii.toString
  if trimmed = "" then
    Doc.empty
  else if trimmed = "unknown" || trimmed = "No battery found" || trimmed = "no drives found" || trimmed = "error running df" then
    ((Doc.text line).ann palette.muted) |> italic
  else
    Doc.text line

private def linesDoc (palette : Palette) (lines : List String) : Doc Style :=
  match lines with
  | [] => valueLineDoc palette "unknown"
  | _ => Layout.vcat (lines.map (valueLineDoc palette))

private def labelDoc (palette : Palette) (k : InfoKey) : Doc Style :=
  ((Doc.text (infoLabel k)).ann palette.secondary) |> bold

private def intersperseBlankLines : List (Doc Style) → List (Doc Style)
  | [] => []
  | [doc] => [doc]
  | doc :: rest => doc :: Doc.empty :: intersperseBlankLines rest

private def labelColumnWidth (group : InfoGroup) : Nat :=
  let widest := group.infos.foldl (fun acc key => max acc (infoLabel key).length) 0
  max 8 (min 18 (widest + 1))

private def visualWidth (text : String) : Nat :=
  text.length

private def maxLineWidthOf (lines : List String) : Nat :=
  match lines with
  | [] => visualWidth "unknown"
  | _ => lines.foldl (fun acc line => max acc (visualWidth line)) 0

private def preferredValueColumnWidth (results : List (InfoKey × List String)) : Nat :=
  let widest := results.foldl (fun acc (_, lines) => max acc (maxLineWidthOf lines)) 0
  max 12 widest

private def terminalWidth : IO Nat := do
  match (← leansi.getTerminalDimensions) with
  | some (_, cols) => pure (max 48 (cols - 2))
  | none => pure 80

private def groupTitleDoc? (palette : Palette) (title? : Option String) : Option (Doc Style) :=
  match title? with
  | some title =>
      some (((Doc.text title).ann palette.primary) |> bold)
  | none => none

private def warningBox (palette : Palette) (maxWidth : Nat) (warnings : List String) : Doc Style :=
  let labelWidth := 10
  let widestWarning := warnings.foldl (fun acc warning => max acc (visualWidth warning)) 24
  let valueWidth := min widestWarning (max 16 (maxWidth - 2 - 4 - labelWidth - 2))
  let content :=
    Layout.vcat (warnings.map fun warning =>
      Layout.columns [labelWidth, valueWidth] 2
        [ ((Doc.text "Config").ann palette.accent) |> bold
        , ((Doc.text warning).ann palette.muted)
        ]
        [Alignment.left, Alignment.left])
  box content {
    title := some ((((Doc.text "Warnings").ann palette.accent) |> bold))
    chars := roundedBoxChars
    borderStyle := palette.accent
    titleAlignment := Alignment.left
    paddingX := 1
    paddingY := 0
    maxWidth := maxWidth
  }

private def renderGroup (palette : Palette) (maxWidth : Nat) (group : InfoGroup) : IO (Doc Style) := do
  let results ← fetchAll group.infos
  let labelWidth := labelColumnWidth group
  let maxValueWidth := max 16 (maxWidth - 2 - 4 - labelWidth - 2)
  let valueWidth := min (preferredValueColumnWidth results) maxValueWidth
  let rows := results.map fun (key, lines) =>
    Layout.columns [labelWidth, valueWidth] 2
      [ labelDoc palette key
      , linesDoc palette lines
      ]
      [Alignment.left, Alignment.left]
  pure <| box (Layout.vcat rows) {
    title := groupTitleDoc? palette group.title
    chars := roundedBoxChars
    borderStyle := palette.primary
    titleAlignment := Alignment.left
    paddingX := 1
    paddingY := 0
    maxWidth := maxWidth
  }

def renderConfig (cfg : Config) : IO (Doc Style) := do
  let width ← terminalWidth
  let palette := paletteOfConfig cfg
  let groupDocs ← cfg.groups.mapM (renderGroup palette width)
  pure <| Layout.vcat (intersperseBlankLines groupDocs)

def renderReport (cfg : Config) (warnings : List String := []) : IO (Doc Style) := do
  let width ← terminalWidth
  let palette := paletteOfConfig cfg
  let groupDocs ← cfg.groups.mapM (renderGroup palette width)
  let docs :=
    match warnings with
    | [] => groupDocs
    | _ => warningBox palette width warnings :: groupDocs
  pure <| Layout.vcat (intersperseBlankLines docs)

def printConfig (cfg : Config) : IO Unit := do
  leansi.println (← renderConfig cfg)

def printReport (cfg : Config) (warnings : List String := []) : IO Unit := do
  leansi.println (← renderReport cfg warnings)

end Lfetch.Output
