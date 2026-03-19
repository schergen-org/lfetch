import Lfetch.Config.Defaults

namespace Lfetch

open Lean

private def configPath : IO System.FilePath := do
  let home ← IO.getEnv "HOME"
  match home with
  | none => pure (System.FilePath.mk ".config/lfetch/config.json")
  | some home => pure (System.FilePath.mk home / ".config" / "lfetch" / "config.json")

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

def loadConfig : IO Config := do
  return (← loadConfigWithWarnings).fst

end Lfetch
