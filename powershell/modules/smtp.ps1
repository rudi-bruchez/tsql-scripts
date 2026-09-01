function Send-DailyCheckReport ($emailFrom, $emailTo, $subject, $body, $smtpServer, $smtpPort = 25) {
    $mail = $null
    $smtp = $null
    try {
        $mail = New-Object System.Net.Mail.MailMessage
        $mail.From = $emailFrom
        foreach ($to in $emailTo) { $mail.To.Add($to) }
        $mail.Subject = $subject
        $mail.Body = $body
        $mail.IsBodyHtml = $true
        $mail.BodyEncoding = [System.Text.Encoding]::UTF8
        $mail.SubjectEncoding = [System.Text.Encoding]::UTF8
        
        $smtp = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
        $smtp.Send($mail)
    } catch {
        $Host.UI.WriteErrorLine("Failed to send email: $_")
        exit 2
    } finally {
        if ($null -ne $mail) { $mail.Dispose() }
        if ($null -ne $smtp) { $smtp.Dispose() }
    }
}