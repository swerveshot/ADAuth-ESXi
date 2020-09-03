Write-Output "***** Creating users in Active Directory"
Import-Module ActiveDirectory
$Password = ConvertTo-SecureString "VMware1!" -AsPlainText -Force

# Waiting for the Active Directory Web Services to become available or the AD CMDlets won't work
(Get-Service -DisplayName "Active Directory Web Services").WaitForStatus('Running')
Start-Sleep -Seconds 3

New-ADUser -Name "vSphereIAM" -GivenName "vSphereIAM" -SamAccountName "vSphereIAM" -UserPrincipalName "vSphereIAM@initiqlabs.local" -Description "User that is granted permissions to change local ESXi credentials" -PasswordNeverExpires:$true -AccountPassword $Password -Enabled $true
New-ADUser -Name "vSphereAdmin" -GivenName "vSphereAdmin" -SamAccountName "vSphereAdmin" -UserPrincipalName "vSphereAdmin@initiqlabs.local" -Description "User that is granted permissions to administer vSphere" -PasswordNeverExpires:$true -AccountPassword $Password -Enabled $true
New-ADGroup -Name "vSphereAdmins" -SamAccountName vSphereAdmins -GroupCategory Security -GroupScope Global -DisplayName "vSphereAdmins" -Description "Users that are granted permissions to administer vSphere"
Add-ADGroupMember -Identity (Get-ADGroup -Identity vSphereAdmins) -Members (Get-ADUser -Identity vSphereAdmin)