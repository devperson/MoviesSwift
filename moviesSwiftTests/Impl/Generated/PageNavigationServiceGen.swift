import Mockable
@testable import moviesSwift

@Mockable
protocol PageNavigationServiceGen : IPageNavigationService
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
