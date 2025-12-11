import XCTest
import Resolver

@testable import moviesSwift

class REST_DI: XCTestCase
{
    override func setUpWithError() throws
    {
        Resolver.RegisterRESTTypes()
    }

    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension Resolver
{
    static func RegisterRESTTypes()
    {
        register { MockLogger() as ILoggingService }.scope(.application)
        register { iOSDirectoryService() as IDirectoryService }.scope(.application)
        register { iOSPreferencesImplementation() as IPreferences }.scope(.application)        
        register { AuthTokenService() as IAuthTokenService }.scope(.application)
        register { RestClient() as IRestClient }.scope(.application)
        register { RequestQueueList() }.scope(.application)
        register { SimpleMessageCenter() as IMessagesCenter }.scope(.application)
        register { ConstantImpl() as IConstant }.scope(.application)
    }
    
//    val authTokenService: IAuthTokenService by inject()
//       private val restClient: IRestClient by inject()
//       private val eventAggregator: IMessagesCenter by inject()
//       private val queueList: RequestQueueList by inject()
//       private val constants: IConstant by inject()
}

