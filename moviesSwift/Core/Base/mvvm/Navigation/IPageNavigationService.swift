import Foundation

protocol IPageNavigationService
{
    func Navigate( _ name: String, parameters: INavigationParameters?, useModalNavigation: Bool, animated: Bool, wrapIntoNav: Bool) async throws
    func NavigateToRoot(parameters: INavigationParameters?) async throws

    func GetCurrentPage() -> IPage?
    func GetCurrentPageModel() -> PageViewModel?
    func GetRootPageModel() -> PageViewModel?
    func GetNavStackModels() -> [PageViewModel]

    var CanNavigateBack: Bool
    {
        get
    }
}

extension IPageNavigationService
{
    func Navigate( _ name: String, parameters: INavigationParameters? = NavigationParameters(), useModalNavigation: Bool = false, animated: Bool = true, wrapIntoNav: Bool = false) async throws
    {
        try await self.Navigate(name, parameters: parameters, useModalNavigation: useModalNavigation, animated: animated, wrapIntoNav: wrapIntoNav)
    }
}
