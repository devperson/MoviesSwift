import Foundation
import Resolver

class Sui_SnackbarBarService: ISnackbarService
{    
    let PopupShowed = Event<SeverityType>()
    
    @LazyInjected
    var pageNavigationService: IPageNavigationService
   

    func ShowError(_ message: String)
    {
        Show(message: message, severityType: SeverityType.Error, duration: 3000)
    }

    func ShowInfo(_ message: String)
    {
        Show(message: message, severityType: SeverityType.Info, duration: 3000)
    }
    
    func Show(message: String, severityType: SeverityType, duration: Int)
    {
        PopupShowed.Invoke(severityType)
        SnackbarManager.shared.show(message: message, severity: severityType)
    }
}
