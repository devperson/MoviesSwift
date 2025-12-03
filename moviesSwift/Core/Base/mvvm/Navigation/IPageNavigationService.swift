import Foundation

protocol IPageNavigationService
{
    func Navigate(name: String, parameters: INavigationParameters?, useModalNavigation: Bool, animated: Bool, wrapIntoNav: Bool) async
    func NavigateToRoot(parameters: INavigationParameters?) async

    func GetCurrentPage() -> IPage?
    func GetCurrentPageModel() -> PageViewModel?
    func GetRootPageModel() -> PageViewModel?
    func GetNavStackModels() -> [PageViewModel]

    var CanNavigateBack: Bool
    {
        get
    }
}
