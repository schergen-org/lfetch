import Lfetch.Config.Defaults

namespace Lfetch

open Lean

/-- Resolves the user config path inside `$HOME/.config/lfetch/config.json`. -/
private def configPath : IO System.FilePath := do
  let home ← IO.getEnv "HOME"
  match home with
  | none => pure (System.FilePath.mk ".config/lfetch/config.json")
  | some home => pure (System.FilePath.mk home / ".config" / "lfetch" / "config.json")

/-- Loads the config file and returns fallback warnings when JSON decoding fails. -/
def loadConfigWithWarnings : IO (Config × List String) := do
  let path ← configPath
  if !(← path.pathExists) then
    return (defaultConfig, [])

  let content ← IO.FS.readFile path
  let parsed? := Json.parse content
  match parsed? with
  | .error err =>
    pure (defaultConfig, [s!"Warning: failed to parse config JSON ({err}). Falling back to default config."])
  | .ok json =>
    match fromJson? json with
    | .error err =>
      pure (defaultConfig, [s!"Warning: invalid config shape ({err}). Falling back to default config."])
    | .ok config =>
      pure (config, [])

/-- Loads the config file and discards any warning messages. -/
def loadConfig : IO Config := do
  return (← loadConfigWithWarnings).fst

end Lfetch
