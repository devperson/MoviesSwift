@testable import moviesSwift

import Foundation

class CustomSnackBarService : ISnackbarService
{
    let PopupShowed = Event<SeverityType>()

    func ShowError(_ message: String)
    {
        PopupShowed.Invoke(SeverityType.Error)
    }

    func ShowInfo(_ message: String)
    {
        PopupShowed.Invoke(SeverityType.Info)
    }

    func Show(message: String, severityType: SeverityType, duration: Int)
    {
        PopupShowed.Invoke(SeverityType.Error)
    }
}
