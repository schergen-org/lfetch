import Lfetch.Core
import Lfetch.Config.Types
import Lfetch.Info.Common
import leansi

namespace Lfetch.Output

open leansi
open leansi.Doc

private structure Palette where
  primary : Style
  secondary : Style
  accent : Style
  muted : Style

private def paletteOfConfig (cfg : Config) : Palette :=
  {
    primary := Style.fg_hex cfg.colors.primary
    secondary := Style.fg_hex cfg.colors.secondary
    accent := Style.fg_hex cfg.colors.accent
    muted := Style.fg_hex cfg.colors.muted
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

private def linesDoc (palette : Palette) (lines : Lfetch.Info.InfoLines) : Doc Style :=
  match lines with
  | [] => italic ((Doc.text "unknown").ann palette.muted)
  | _ => Layout.vcat lines

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

private def maxLineWidthOf (lines : Lfetch.Info.InfoLines) : Nat :=
  match lines with
  | [] => visualWidth "unknown"
  | _ => lines.foldl (fun acc line => max acc (docVisualLength line)) 0

private def preferredValueColumnWidth (results : List (InfoKey × Lfetch.Info.InfoLines)) : Nat :=
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

/-- A small palette strip mirrors the color blocks often shown by fetch tools. -/
private def paletteDoc (cfg : Config) : Doc Style :=
  let swatch (hex : String) : Doc Style := Doc.text "  " |> bg_hex hex
  let row :=
    Layout.hcatSep 1
      [ swatch cfg.colors.primary
      , swatch cfg.colors.secondary
      , swatch cfg.colors.accent
      , swatch cfg.colors.muted
      ]
  ((Doc.text "Palette").ann (Style.fg_hex cfg.colors.secondary) |> bold) ++ (Doc.text " ") ++ row

private def appendPalette (cfg : Config) (docs : List (Doc Style)) : List (Doc Style) :=
  docs ++ [Doc.empty, paletteDoc cfg]

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

private def renderGroup (cfg : Config) (palette : Palette) (maxWidth : Nat) (group : InfoGroup) : IO (Doc Style) := do
  let results ← fetchAll cfg.colors group.infos
  let labelWidth := labelColumnWidth group
  let maxValueWidth := max 16 (maxWidth - 2 - 4 - labelWidth - 2)
  let valueWidth := min (preferredValueColumnWidth results) maxValueWidth
  let baseRows := results.map fun (key, lines) =>
  Layout.columns [labelWidth, valueWidth] 2
    [ labelDoc palette key
    , linesDoc palette lines
    ]
    [Alignment.left, Alignment.left]
  let rows :=
    match group.padding with
    | none => baseRows
    | some p =>
      let spacer := List.replicate p (Doc.empty)
      baseRows.foldr (fun row acc =>
        match acc with
        | [] => [row]  -- last Element (no Spacer after that)
        | _  => row :: spacer ++ acc
      ) []
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
  let groupDocs ← cfg.groups.mapM (renderGroup cfg palette width)
  pure <| Layout.vcat (appendPalette cfg (intersperseBlankLines groupDocs))

def renderReport (cfg : Config) (warnings : List String := []) : IO (Doc Style) := do
  let width ← terminalWidth
  let palette := paletteOfConfig cfg
  let groupDocs ← cfg.groups.mapM (renderGroup cfg palette width)
  let docs :=
    match warnings with
    | [] => groupDocs
    | _ => warningBox palette width warnings :: groupDocs
  pure <| Layout.vcat (appendPalette cfg (intersperseBlankLines docs))

def printConfig (cfg : Config) : IO Unit := do
  leansi.println (← renderConfig cfg)

def printReport (cfg : Config) (warnings : List String := []) : IO Unit := do
  leansi.println (← renderReport cfg warnings)

end Lfetch.Output
