
import Foundation
import Resolver
@testable import moviesSwift


final class CustomPageNavigationService : IPageNavigationService
{
    

    // MARK: - Fields

    private var ViewModelStackList: [PageViewModel] = []

    // MARK: - Properties

    var CanNavigateBack: Bool
    {
        return ViewModelStackList.count > 1
    }

    // MARK: - Navigation

    func Navigate(
        _ name: String,
        parameters: INavigationParameters?,
        useModalNavigation: Bool,
        animated: Bool,
        wrapIntoNav: Bool
    ) async
    {
        GetCurrentPageModel()?.OnDisappearing()

        var newPageName = name

        if name.contains("../")
        {
            let splitCount = name.split(separator: "/").filter { $0 == ".." }.count

            for _ in 0..<splitCount
            {
                GetCurrentPageModel()?.Destroy()
                if !ViewModelStackList.isEmpty
                {
                    _ = ViewModelStackList.popLast()
                }
            }

            newPageName = name.replacingOccurrences(of: "../", with: "")
        }
        else if name.contains("/")
        {
            ViewModelStackList.forEach { $0.Destroy() }
            ViewModelStackList.removeAll()

            newPageName = name.replacingOccurrences(of: "/", with: "")
        }

        if newPageName.isEmpty
        {
            if name.contains("../"),
               let parameters,
               parameters.Count() > 0
            {
                GetCurrentPageModel()?.OnNavigatedTo(parameters)
            }
            return
        }

        // Resolve directly from Resolver using the registered name
        let viewModel: PageViewModel = ContainerLocator.Resolve(name: newPageName)

        let params = parameters ?? NavigationParameters()
        viewModel.Initialize(params)
        viewModel.OnNavigatedTo(params)
        viewModel.OnAppearing()
        // viewModel.OnAppeared()

        GetCurrentPageModel()?.OnNavigatedFrom(NavigationParameters())

        ViewModelStackList.append(viewModel)
    }

    func NavigateToRoot(parameters: INavigationParameters?) async
    {
        while ViewModelStackList.count > 1
        {
            let current = ViewModelStackList.removeLast()
            current.Destroy()
        }
    }

    // MARK: - Getters

    func GetCurrentPage() -> IPage?
    {
        fatalError("Not yet implemented")
    }

    func GetCurrentPageModel() -> PageViewModel?
    {
        return ViewModelStackList.last
    }

    func GetRootPageModel() -> PageViewModel?
    {
        fatalError("Not yet implemented")
    }

    func GetNavStackModels() -> [PageViewModel]
    {
        return ViewModelStackList
    }
}
