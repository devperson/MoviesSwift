import Foundation

class EmailMessage
{
    public var Subject: String?
    public var Body: String?
    public var BodyFormat: EmailBodyFormat = .PlainText
    public var To: [String]
    public var Cc: [String]
    public var Bcc: [String]
    public var Attachments: [EmailAttachment]

    init()
    {
        self.Subject = nil
        self.Body = nil
        self.To = []
        self.Cc = []
        self.Bcc = []
        self.Attachments = []
    }

    init(subject: String, body: String, to: [String])
    {
        self.Subject = subject
        self.Body = body
        self.To = to
        self.Cc = []
        self.Bcc = []
        self.Attachments = []
    }
}
