import Lfetch.Info.Common

namespace Lfetch.Info.Dummy

/-- Returns a placeholder entry for unfinished or example providers. -/
def fetch (_colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  pure [Lfetch.Info.textDoc "TODO(dummy-info)"]

end Lfetch.Info.Dummy
