import Mockable
@testable import moviesSwift

@Mockable
protocol AlertDialogServiceGen : IAlertDialogService
{
    func DisplayAlert(title: String, message: String, cancel: String) async throws
    func ConfirmAlert(title: String, message: String, buttons: [String]) async throws -> Bool

    func DisplayActionSheet(title: String, buttons: [String]) async throws -> String?
    func DisplayActionSheet(title: String, cancel: String?, destruction: String?, buttons: [String]) async throws -> String?
}

