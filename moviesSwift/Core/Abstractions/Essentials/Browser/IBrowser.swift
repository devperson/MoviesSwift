import Foundation

/// <summary>
/// Provides a way to display a web page inside an app.
/// </summary>
protocol IBrowser
{
    /// <summary>
    /// Open the browser to specified URI.
    /// </summary>
    /// <param name="uri">URI to open.</param>
    /// <returns>Completed task when browser is launched, but not necessarily closed. Result indicates if launching was successful or not.</returns>
    func OpenAsync(_ uri: String) async throws -> Bool

    /// <summary>
    /// Open the browser to specified URI.
    /// </summary>
    /// <param name="uri">URI to open.</param>
    /// <param name="options">Launch options for the browser.</param>
    /// <returns>Completed task when browser is launched, but not necessarily closed. Result indicates if launching was successful or not.</returns>
    func OpenAsync(_ uri: String, options: BrowserLaunchOptions) async throws -> Bool
}
