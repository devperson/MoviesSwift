import Foundation

protocol IPageLifecycleAware
{
    func OnAppearing()
    func OnDisappearing()

    func ResumedFromBackground(_ arg: Any?)
    func PausedToBackground(_ arg: Any?)
}
