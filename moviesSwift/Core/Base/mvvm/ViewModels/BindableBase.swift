import Foundation


class BindableBase : LoggableService, ObservableObject
{
    /// Forces SwiftUI to refresh any views observing this object,
    /// even if no properties have actually changed.
    func InvalidateView()
    {
        objectWillChange.send()   // 🔥 notify
    }
}

