import Foundation

// Converted NavRegistrar: a lightweight Swift registrar to map ViewModel names to page/viewmodel factories.
// Note: original Kotlin implementation used Koin; this Swift version is a simple registry.
class NavRegistrar
{
    public var navPages: [NavPageInfo] = []

    func RegisterPageForNavigation<TPage: IPage, TVm: PageViewModel>(vmName: String, createPage: @escaping () -> TPage, createViewModel: @escaping () -> TVm) throws
    {
        if navPages.contains(where: { $0.vmName == vmName })
        {
            throw NSError(domain: "NavRegistrar", code: 1, userInfo: [NSLocalizedDescriptionKey: "ViewModel '\(vmName)' was already registered for navigation."])
        }
        let info = NavPageInfo(vmName: vmName, createPageFactory: { createPage() as IPage }, createVmFactory: { createViewModel() as PageViewModel })

        navPages.append(info)
    }

    func CreatePage(vmName: String, parameters: INavigationParameters) throws -> IPage
    {
        guard let pageInfo = navPages.first(where: { $0.vmName == vmName })
        else
        {
            throw NSError(domain: "NavRegistrar", code: 1, userInfo: [NSLocalizedDescriptionKey: "ViewModel '\(vmName)' was not registered for navigation."])
        }

        var page = pageInfo.createPageFactory()
        let vm = pageInfo.createVmFactory()
        page.ViewModel = vm
        vm.Initialize(parameters)
        return page
    }
}
