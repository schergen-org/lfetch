import Std

namespace Lfetch.Info.OS

private def trimLine (s : String) : String :=
  (s.trimAscii).toString

private def stripQuotes (s : String) : String :=
  if s.startsWith "\"" && s.endsWith "\"" && s.length ≥ 2 then
    -- drop/dropRight liefern hier String.Slice -> wieder zu String konvertieren
    ((s.drop 1).dropEnd 1).toString
  else
    s

private def parseOsReleaseValue (content : String) (wanted : String) : Option String :=
  let lines := content.splitOn "\n"
  let rec go : List String → Option String
    | [] => none
    | line :: rest =>
      let line := trimLine line
      if line = "" || line.startsWith "#" then
        go rest
      else
        match line.splitOn "=" with
        | [] => go rest
        | [_] => go rest
        | k :: v :: more =>
          let k := trimLine k
          let v :=
            String.intercalate "=" (v :: more)
            |> trimLine
            |> stripQuotes
            |> trimLine
          if k = wanted then some v else go rest
  go lines

private def readOsRelease : IO (Option String) := do
  let path : System.FilePath := "/etc/os-release"
  if (← path.pathExists) then
    let content ← IO.FS.readFile path
    match parseOsReleaseValue content "PRETTY_NAME" with
    | some v => pure (some v)
    | none =>
      let name  := parseOsReleaseValue content "NAME"
      let ver   := parseOsReleaseValue content "VERSION"
      let verId := parseOsReleaseValue content "VERSION_ID"
      match name with
      | none => pure none
      | some n =>
        let v :=
          match ver with
          | some vv => s!"{n} {vv}"
          | none =>
            match verId with
            | some vv => s!"{n} {vv}"
            | none    => n
        pure (some v)
  else
    pure none

private def unameFallback : IO String := do
  try
    let out ← IO.Process.output { cmd := "uname", args := #["-sr"] }
    if out.exitCode = 0 then
      pure (trimLine out.stdout)
    else
      pure "unknown"
  catch _ =>
    pure "unknown"

def fetch : IO String := do
  match (← readOsRelease) with
  | some os => pure os
  | none    => unameFallback

end Lfetch.Info.OS
