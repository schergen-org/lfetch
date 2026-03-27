import Std
import Lfetch.Info.Common

namespace Lfetch.Info.Shell

-- From https://github.com/dylanaraps/neofetch/blob/master/neofetch
/-- Run shell commands -/
private def runShell (shell cmd : String) : IO String := do
  let out ← IO.Process.output {
    cmd := shell
    args := #["-c", cmd]
  }
  return out.stdout.trimAscii.toString

/-- Removes the first occurrence of a substring -/
private def removeFirst (s sub : String) : String :=
  match s.splitOn sub with
  | []      => s
  | x :: xs => x ++ String.intercalate sub xs

private def getShellVersion (shellName : String) : IO String := do
  match shellName with
  | "bash" => do
      let v ← runShell "bash" "printf %s \"$BASH_VERSION\""
      pure (v.splitOn "(" |>.headD v)

  | "sh" | "ash" | "dash" | "es" =>
      pure ""

  | "osh" =>
      let v ← runShell "osh" "printf %s \"$OIL_VERSION\""
      pure v

  | "tcsh" => do
      runShell "tcsh" "printf %s $tcsh"

  | "yash" => do
      let v ← runShell "yash" "--version"
      let v := removeFirst v s!" {shellName}"
      let v := removeFirst v " Yet another shell"
      let v := removeFirst v "Copyright"
      pure v

  | "nu" => do
      let v ← runShell "nu" "version | get version"
      pure (removeFirst v s!" {shellName}")

  | name =>
    if name.endsWith "ksh" then do
      let v ← runShell name "printf %s \"$KSH_VERSION\""
      let v := removeFirst v " KSH"
      let v := removeFirst v "version"
      pure v
    else do
      let v ← IO.Process.output {
        cmd := name
        args := #["--version"]
      }
      pure (removeFirst v.stdout.trimAscii.toString s!" {shellName}")

/-- Reports the shell path and version from the current process environment. -/
def fetch (colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  match (← IO.getEnv "SHELL") with
  | some sh =>
    let name := sh.takeEndWhile (fun c => c != '/') |> toString
    let version ← getShellVersion name
    pure [Lfetch.Info.textDoc (name ++ " " ++ version)]
  | none    => pure [Lfetch.Info.unknownDoc colors]

end Lfetch.Info.Shell
