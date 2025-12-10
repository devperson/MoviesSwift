//import Foundation
import SafariServices
import UIKit

class IOSBrowserImplementation: IBrowser
{
    func OpenAsync(_ uri: String) async throws -> Bool
    {
        return try await OpenAsync(uri, options: BrowserLaunchOptions())
    }

    func OpenAsync(_ uri: String, options: BrowserLaunchOptions) async throws -> Bool
    {
        switch options.LaunchMode
        {
        case .SystemPreferred:
            await LaunchSafariViewController(uri: uri, options: options)

        default:
            // Not implemented
            fatalError("Feature not implemented: External launch mode.")
        }
        return true
    }

    @MainActor
    func LaunchSafariViewController(uri: String, options: BrowserLaunchOptions) async
    {
        guard let nativeUrl = URL(string: uri) else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false

        let safariVC = SFSafariViewController(url: nativeUrl, configuration: config)

        //guard let vc = CurrentController.GetTopViewController() else { return }

        
        // Toolbar color
        if let toolbarColor = options.PreferredToolbarColor {
            safariVC.preferredBarTintColor = toolbarColor.ToUIColor()
        }

        // Control color
        if let controlColor = options.PreferredControlColor {
            safariVC.preferredControlTintColor = controlColor.ToUIColor()
        }

        // Popover source
        if let popover = safariVC.popoverPresentationController {
            //popover.sourceView = vc.view
        }

        // Presentation style
        if options.Flags == .PresentAsFormSheet
        {
            safariVC.modalPresentationStyle = .formSheet
        } else if options.Flags == .PresentAsPageSheet
        {
            safariVC.modalPresentationStyle = .pageSheet
        }

        //vc.present(safariVC, animated: true)
    }
}
