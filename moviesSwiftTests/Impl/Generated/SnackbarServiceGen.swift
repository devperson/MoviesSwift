
import Mockable
@testable import moviesSwift

@Mockable
protocol SnackbarServiceGen : ISnackbarService
{
    var PopupShowed: Event<SeverityType> { get }
    func ShowError(_ message: String);
    func ShowInfo(_ message: String);
    func Show(message: String, severityType: SeverityType, duration: Int);
}

