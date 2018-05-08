<#
.SYNOPSIS
    .
.DESCRIPTION
    Windows scheduled task to disable and delete users from the active directory.
.EXAMPLE
    .
.NOTES
    Author: Mark Malburg
    Date:   May 2018
#>

Import-Module ActiveDirectory

#Variables for disabling/deleting
$today = Get-Date.ToString('MMddyyyy')
$server = fs.elon.edu
$disfileToday = "C:\\scripts\\ADscripts\\disabledelete\\Disable Lists\\fs"+$today+".txt"
$delfileToday = "C:\\scripts\\ADscripts\\disabledelete\\Delete Lists\\fs"+$today+".txt"

#Removes the user from groups
Get-Content $disfileToday | foreach {
	$user = Get-ADUser -server $server $_ -properties MemberOf
	$user.MemberOf | foreach-object {
		Remove-ADGroupMember -server $server -identity $user.MemberOf -members $user.sAMAccountName
	}

	#Variables for email
	$messageFrom =  "sysadmin@elon.edu"
	$messageTo = "sysadmin@elon.edu;clott2@elon.edu;aallred@elon.edu"
	$messageSubject = "Disabled User: " + $user.sAMAccountName
	$messageBody = "User " + $user.sAMAccountName + " has been removed from all group memberships."
	$smtpServer = "smtp.elon.edu"

	#Sends email
	Write-Host "Sending group removal email"
	send-mailmessage -from $messageFrom -to $messageTo -subject $messageSubject -body $messageBody -BodyAsHtml -smtpServer $smtpServer
}
	
#Disables the user in the active directory and changes the OU to disabled
$outarget = "OU=Disabled,OU=All Users,DC=fs,DC=elon,DC=edu"
Get-Content $disfileToday | foreach {
	Disable-ADAccount -server $server $_
	Get-ADUser -server $server $_ | Move-ADObject -server $server -targetpath $outarget
	
	#Variables for email
	$messageFrom =  "sysadmin@elon.edu"
	$messageTo = "sysadmin@elon.edu;clott2@elon.edu;aallred@elon.edu"
	$messageSubject = "Disabled User: " + $_
	$messageBody = "User " + $_ + " has been disabled from the active directory."
	$smtpServer = "smtp.elon.edu"

	#Sends email
	Write-Host "Sending disabled email"
	send-mailmessage -from $messageFrom -to $messageTo -subject $messageSubject -body $messageBody -BodyAsHtml -smtpServer $smtpServer
}

#Removes the user from the address book
Get-Content $disfileToday | foreach {
	Set-ADUser -server $server $_ -Replace @{msExchHideFromAddressLists="TRUE"}
	
	#Variables for email
	$messageFrom =  "sysadmin@elon.edu"
	$messageTo = "sysadmin@elon.edu;clott2@elon.edu;aallred@elon.edu"
	$messageSubject = "Disabled User: " + $_
	$messageBody = "User " + $_ + " has been hidden from all address lists."
	$smtpServer = "smtp.elon.edu"

	#Sends email
	Write-Host "Sending address list removal email"
	send-mailmessage -from $messageFrom -to $messageTo -subject $messageSubject -body $messageBody -BodyAsHtml -smtpServer $smtpServer
}

#Changes the user's OU status to deleted
$outarget = "OU=Deleted,OU=All Users,DC=fs,DC=elon,DC=edu"
Get-Content $delfileToday | foreach {
	Get-ADUser -server $server $_ | Move-ADObject -server $server -targetpath $outarget
	
	#Variables for email
	$messageFrom =  "sysadmin@elon.edu"
	$messageTo = "sysadmin@elon.edu;clott2@elon.edu;aallred@elon.edu"
	$messageSubject = "Deleted User: " + $_
	$messageBody = "User " + $_ + " has been moved to the deleted OU."
	$smtpServer = "smtp.elon.edu"

	#Sends email
	Write-Host "Sending deleted OU email"
	send-mailmessage -from $messageFrom -to $messageTo -subject $messageSubject -body $messageBody -BodyAsHtml -smtpServer $smtpServer
}



