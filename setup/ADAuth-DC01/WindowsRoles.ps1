Write-Output "***** Installing DNS & AD Roles"
Import-Module ServerManager -Verbose
Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools -Verbose -Confirm:$false

# Creating active directory forest
Import-Module ADDSDeployment -Verbose
$SafeModePW = ConvertTo-SecureString "VMware1!" -AsPlainText -Force
Install-ADDSForest -Verbose -SafeModeAdministratorPassword $SafeModePW -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName "initiqlabs.local" -DomainNetbiosName "INITIQLABS" -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$true -SysvolPath "C:\Windows\SYSVOL" -Force:$true