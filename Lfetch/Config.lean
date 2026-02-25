namespace Lfetch

inductive InfoKey
  | dummy
  | os
  | user
  | shell
  deriving Repr, DecidableEq

def InfoKey.toString : InfoKey → String
  | .dummy  => "dummy"
  | .os     => "os"
  | .user   => "user"
  | .shell  => "shell"

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

def InfoKey.parse (s : String) : Option InfoKey :=
  match (trimLine s).toLower with
  | "dummy"     => some .dummy
  | "os"        => some .os
  | "user"      => some .user
  | "shell"     => some .shell
  | _        => none

structure Config where
  keys : List InfoKey
  deriving Repr

def defaultConfig : Config :=
  { keys := [.dummy] }

private def configPath : IO System.FilePath := do
  let home ← IO.getEnv "HOME"
  match home with
  | none      => pure (System.FilePath.mk ".config/lfetch/config")
  | some home => pure (System.FilePath.mk home / ".config" / "lfetch" / "config")

def loadConfig : IO Config := do
  let path ← configPath
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    let keys :=
      content.splitOn "\n"
      |>.map trimLine
      |>.filter (fun line => line ≠ "" && !line.startsWith "#")
      |>.filterMap InfoKey.parse
    pure { keys := keys }
  else
    pure defaultConfig

end Lfetch
