import Foundation

/**
 * Provides an easy way to allow the user to send emails.
 */
protocol IEmail {
    /**
     * Gets a value indicating whether composing an email is supported on this device.
     */
    var IsComposeSupported: Bool { get }

    /**
     * Opens the default email client to allow the user to send the message.
     * @param message Instance of EmailMessage containing details of the email message to compose.
     * @return A suspend function representing the asynchronous operation.
     */
    func Compose(_ message: EmailMessage)
}
