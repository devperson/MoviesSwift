import Foundation

protocol IAlertDialogService
{
    func DisplayAlert(title: String, message: String, cancel: String) async
    func ConfirmAlert(title: String, message: String, vararg buttons: String) async -> Bool

    func DisplayActionSheet(title: String, vararg buttons: String) async -> String?
    func DisplayActionSheet(title: String, cancel: String?, destruction: String?, vararg buttons: String) async -> String?
}


