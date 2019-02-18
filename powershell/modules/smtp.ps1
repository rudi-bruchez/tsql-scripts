Function sendEmail([string]$emailFrom, [string]$emailTo, [string]$subject,[string]$body,[string]$smtpServer,[string]$filePath)
{
#initiate message
$email = New-Object System.Net.Mail.MailMessage
$email.From = $emailFrom
$email.To.Add($emailTo)
$email.Subject = $subject
$email.Body = $body
# initiate email attachment
$emailAttach = New-Object System.Net.Mail.Attachment $filePath
$email.Attachments.Add($emailAttach)
#initiate sending email
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($email)
}