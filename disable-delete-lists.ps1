<#
.SYNOPSIS
    .
.DESCRIPTION
    Adds users that need to be disabled and deleted to files for the scheduled task to handle.
.PARAMETER date
	The initial date that the disable delete request was inputted.
.PARAMETER username 
    The username to be disabled and deleted.
.PARAMETER type
	The type of account - "student" or "facstaff"
.EXAMPLE
    .\disable-delete-list.ps1 -date date1 -username generic1 -type student
.NOTES
    Author: Mark Malburg
    Date:   April 2018
#>

	
#Input from user: date username type
param(
	[string]$date = $(throw "-date is required"),
	[string]$username = $(throw "-username is required"),
	[string]$type = $(throw "-account type is required")
	)
	
Import-Module ActiveDirectory

#Converts the string entered as the date to a DateTime object
$inputDate = [DateTime]$date

#If the account type is a student, the disable date is set immediately, the delete date
#is set to 60 days from the entered time, and the action is set to "Withdraw". Otherwise,
#the disable date is set to 30 days from the entered time, the delete date is set to 90
#days from the entered time, and the action is set to "Former Employee".
if ($type -eq "student")
{
	$disdate = $inputDate -f 'MMddyyyy'
	$deldate = $inputDate.AddDays(60) | Get-Date -UFormat %m%d%Y 
	$action = "Withdraw"
}
else
{
	$disdate = $inputDate.AddDays(30) | Get-Date -UFormat %m%d%Y
	$deldate = $inputDate.AddDays(90) | Get-Date -UFormat %m%d%Y
	$action = "Former Employee"
}

#Outputs the disable and delete dates to the console, as well as the action to be performed
Write-Host "Disable date: " $disdate
Write-Host "Delete date: " $deldate
Write-Host "Action: " $action

#Adds the username to the text files for disabled and deleted users
$disfile = "C:\\scripts\\ADscripts\\disabledelete\\Disable Lists\\fs"+$disdate+".txt"
$delfile = "C:\\scripts\\ADscripts\\disabledelete\\Delete Lists\\fs"+$deldate+".txt"
Add-Content $disfile $username
Add-Content $delfile $username

#Variables for email
$messageFrom =  "sysadmin@elon.edu"
$messageTo = "sysadmin@elon.edu;clott2@elon.edu;aallred@elon.edu"
$messageSubject = $action + " " + $username
$messageBody = "User " + $username + "<p>Disable Date: " + $disdate + "<p>Delete Date: " + $deldate
$smtpServer = "smtp.elon.edu"

#Sends an email giving information on the user that has been prompted for disable and deletion
Write-Host "Sending email"
send-mailmessage -from $messageFrom -to $messageTo -subject $messageSubject -body $messageBody -BodyAsHtml -smtpServer $smtpServer