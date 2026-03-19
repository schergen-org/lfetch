import Lfetch.Info.Common

namespace Lfetch.Info.Dummy

def fetch (_colors : Lfetch.Colors) : IO Lfetch.Info.InfoLines := do
  pure [Lfetch.Info.textDoc "TODO(dummy-info)"]

end Lfetch.Info.Dummy
