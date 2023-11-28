Import-Module ActiveDirectory
function Send-Mail ($to)      {

$cred = get-credential -credential "#email@domain.com#"
$From = "#email@domain.com#"
$To = "#email@domain.com#"
$SMTPServer = "smtp.office365.com"
$SMTPPort = "587"
$subject = "Password Expiration Notification"
$SMTPClient = New-Object Net.Mail.SmtpClient($SMTPServer,$SMTPPort) 
$SMTPClient.EnableSsl = $true
$message = "Hello, 

This is a reminder that your password is set to expire in three days or less. Because we often see authentication/lock out issues when we change passwords, we ask that you please change it today rather than over the weekend.  This way we are better able to assist if an issue arises.
                                                                                                                                                                       

To change your password - US On-site Employees

1.  Press CTRL + ALT + DEL
2.  Select 'Change Your Password...'
3.  Enter your existing password and then your new desired password
4.  Update any mobile device that uses COMPANY email with your new password



To change your password - Off-site or Traveling Employees

1.  Log into https://citrix.COMPANY.com
2.  Select the Accessories folder
3.  Select COMPANY Password Tool
4.  Follow the prompts to change your password
5.  Update any mobile device that uses COMPANY email with your new password

Password Complexity Rules:
- must be at least 6 characters
- must contain three of the following: uppercase character, lowercase character, numerical value, special character
- cannot contain parts of your first or last name

Clearing your Credential manager:
Your local computer saves your passwords in the Credential Manager. It is important to clear out your old password, so it does not lock you out of your account. Please see the attached instructions on how to clear your credential manager. 



Please contact Helpdesk@wirecoworldgroup.com if you need any assistance resetting your password."
$message.isbodyhtml = $true 
$SMTPClient.Credentials = new-object system.net.networkcredential($cred.GetNetworkCredential().UserName,$cred.GetNetworkCredential().Password)
$SMTPClient.Send($message)}


$Users = get-aduser -filter {(Enabled -eq $true) -and (PasswordNeverExpires -eq $false)} -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |
        where { $_.passwordexpired -eq $false }  | 
            select passwordlastset, EmailAddress | 
               
        foreach     {
            New-Object -TypeName psobject @{
            Expires = ((get-date) - $_.PasswordLastSet).totaldays
            Email = $_.emailaddress
                    } }

$targets =   $Users | Where-Object{$_.expires -gt 176 -and $_.expires -lt 180} | foreach send-
   



