import Foundation

/**
 * Represents various types of email body formats.
 */
public enum EmailBodyFormat
{
    /**
     * The email message body is plain text.
     */
    case PlainText

    /**
     * The email message body is HTML (not supported on Windows).
     */
    case Html
}
