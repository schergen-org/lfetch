import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Shell

-- From https://github.com/dylanaraps/neofetch/blob/master/neofetch
/-- Run shell commands -/
private def runShell (shell : String) (args : Array String) : IO String := do
  try
    let out ← IO.Process.output { cmd := shell, args := args }
    if out.exitCode = 0 then
      return out.stdout.trimAscii.toString
    else
      return ""
  catch _ =>
    return ""

/-- Removes the first occurrence of a substring -/
private def removeFirst (s sub : String) : String :=
  match s.splitOn sub with
  | []      => s
  | x :: xs => x ++ String.intercalate sub xs

private def getShellVersion (shellName path : String) : IO String := do
  match shellName with
  | "bash" => do
      let v ← runShell path #["-c", "printf %s \"$BASH_VERSION\""]
      pure (v.splitOn "(" |>.headD v)

  | "sh" | "ash" | "dash" | "es" =>
      pure ""

  | "osh" =>
      let v ← runShell path #["-c", "printf %s \"$OIL_VERSION\""]
      pure v

  | "tcsh" => do
      runShell path #["-c", "printf %s \"$tcsh\""]
  | "yash" => do
      let v ← runShell path #["--version"]
      let v := removeFirst v s!" {shellName}"
      let v := removeFirst v " Yet another shell"
      let v := removeFirst v "Copyright"
      pure v

  | "nu" => do
      let v ← runShell "nu" #["-c", "version | get version"]
      pure (removeFirst v s!" {shellName}")

  | name =>
    if name.endsWith "ksh" then do
      let v ← runShell path #["-c", "printf %s \"$KSH_VERSION\""]
      let v := removeFirst v " KSH"
      let v := removeFirst v "version"
      pure v
    else do
      let v ← runShell path #["--version"]
      pure (removeFirst v s!" {shellName}")

/-- Reports the shell path and version from the current process environment. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "SHELL") with
  | some sh =>
    let name := sh.takeEndWhile (fun c => c != '/') |> toString
    let version ← getShellVersion name sh
    pure [Lfetch.Info.textDoc (name ++ " " ++ version)]
  | none    => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Shell
