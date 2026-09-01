function Send-DailyCheckReport ($emailFrom, $emailTo, $subject, $body, $smtpServer, $smtpPort = 25, $enableSsl = $false, $credential = $null) {
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
        $smtp.EnableSsl = [bool]$enableSsl
        if ($null -ne $credential) {
            $smtp.UseDefaultCredentials = $false
            $smtp.Credentials = $credential.GetNetworkCredential()
        } else {
            $smtp.UseDefaultCredentials = $true
        }
        $smtp.Send($mail)
    } catch {
        throw "Failed to send email: $_"
    } finally {
        if ($null -ne $mail) { $mail.Dispose() }
        if ($null -ne $smtp) { $smtp.Dispose() }
    }
}