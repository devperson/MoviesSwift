import Foundation
@testable import moviesSwift

class NavigatableTest : IntegrationDI
{
    // Called after every test
    func LogOut()
    {
        LogMessage("***********TEST method ends****************")
    }
    
    func GetCurrentPage() -> PageViewModel?
    {
        let navigation: IPageNavigationService = ContainerLocator.Resolve()
        return navigation.GetCurrentPageModel()
    }
    
    func EnsureNoError() throws
    {
        var log:ILoggingService = ContainerLocator.Resolve()
        if (log.HasError)
        {
            let exc = log.LastError
            log.LastError = nil
            throw LogLastErrorException("There is error appens during test", cause: exc)
        }
    }
    
    func Navigate(name: String) async
    {
        let nav:IPageNavigationService = ContainerLocator.Resolve()
        try! await nav.Navigate(name)
    }
    
    func ThrowWrongPageError<CorrectPageT : PageViewModel>(wrongPage: PageViewModel, nilParam: CorrectPageT? = nil) throws
    {
        let correctPageName = String(describing: CorrectPageT.self)
        let wrongPageName = String(describing: wrongPage.self)
        let error = "App should be navigated to \(correctPageName) but navigated to \(wrongPageName)."
        try ThrowException(message: error)
    }
    
    func GetNextPage<T : PageViewModel>() throws -> T
    {
        try EnsureNoError()
        let page = GetCurrentPage()
        guard let page = page else
        {
            throw LogLastErrorException("No current page")
        }
        if (page is T)
        {
            return page as! T
        }
        else
        {
            try ThrowWrongPageError(wrongPage: page)
        }
        
        throw AppException("This line should bever executed")
    }
    
    // Helper placeholders (to be implemented in your test framework)
    func LogMessage(_ message: String)
    {
        print(message)
    }
    
    func ThrowException(message: String) throws
    {
        throw LogLastErrorException(message)
    }
}

class LogLastErrorException : AppException
{
//    override init(_ meesage: String, cause: Error?)
//    {
//        super.init(Message, cause: cause)
//    }
}
