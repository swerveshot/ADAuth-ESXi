<#
Script to set AD Authentication for ESXi server(s)

Todo:

On AD pre-joining
- [✓] Create a user vSphereAdmin in AD for use with vSphere
- [✓] Create a group vSphereAdmins in AD for use with vSphere and assign the vSphereAdmin
- [✓] Create a vSphereIAM user in AD for changing ESXi local account passwords
- [ ] Optional: Create a user vSphereJoinAD in AD that can join computers to the domain 

On ESXi pre-joining
- [✓] [powershell] Set ESXi FQDN to AD Domain
- [✓] [powershell] Set ESXi DNS server to AD server
- [✓] [powershell] Join ESXi to the AD Domain
- [✓] [powershell] Create a custom role vSphere IAM Access on ESXi for managing local accounts with privileges Host.Local.ManageUserGroups, Authorization.ModifyPermissions

On ESXi post-joining
- [✓] [powershell] Add the vSphere AD group to the Admin role
- [✓] [powershell] Add the vSphereIAM user to the vSphere IAM Access role
#>

param (
   [Parameter(Mandatory=$true, HelpMessage="VM Hostname or IP")]
   [ValidateNotNull()]
   [string[]]
   $VMHost,

   [Parameter(Mandatory=$true, HelpMessage="AD Server IP")]
   [ValidateNotNull()]
   [string[]]
   $ADServer
)

$vmHostUserName = "root"
$vmHostPassword = "VMware1!"
$vmHostName = "adauth-esxi01"
$domainlFullName = "initiqlabs.local"
$domainAlias = "INITIQLABS"
$domainUser = "administrator"
$domainPassword = "VMware1!"
$GroupNameToGrantPermissions = "vSphereAdmins"
$roleName = "Admin"
$IAMRoleName = "vSphere IAM Access"
$UserNameToGrantPermissions = "vSphereIAM"

# Establish connection to a VMHost
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false -Scope Session
$vmHostConnection= Connect-VIServer -Server $VMHost -User $vmHostUserName -Password $vmHostPassword

try {
        # Get VMHost instance
        $vmHostinstance= Get-VMHost -Server $vmHostConnection

        Write-Output "***** Set Hostname and DNS Server"
        Get-VMHostNetwork -VMHost $vmHostinstance | Set-VMHostNetwork -HostName $vmHostName -DomainName $domainlFullName -DNSAddress $ADServer

        Write-Output "***** Join the VMHost to a domain"
        Get-VMHostAuthentication -VMHost $vmHostinstance | Set-VMHostAuthentication -Domain $domainlFullName -User $domainUser -Password $domainPassword -JoinDomain -Confirm:$false


        Write-Output "***** Add permissions on VMHost"
        # Get a domain account
        $viAccount= Get-VIAccount -Domain $domainAlias -Group -Id $GroupNameToGrantPermissions        
        if (-not $viAccount) {
              throw "VIAccount with Id '$GroupNameToGrantPermissions' not found in domain '$domainAlias'"
        }

        # Get role to assign
        $viRole= Get-VIRole -Name $roleName
        if (-not $viRole) {
              throw "VIRole with name '$viRole' not found."
        }
        
        # Add permissions on VMHost
        New-VIPermission -Principal $viAccount -Role $viRole -Entity $vmHostinstance      

        # Add role for identity manager
        New-VIRole -name "vSphere IAM Access" -Privilege (Get-VIPrivilege -Id Host.Local.ManageUserGroups, Authorization.ModifyPermissions) -Confirm:$false

        # Get role to assign
        $viRole= Get-VIRole -Name $IAMroleName
        if (-not $viRole) {
              throw "VIRole with name '$viRole' not found."
        }

        # Get a domain account
        $viAccount= Get-VIAccount -Domain $domainAlias -User -Id $UserNameToGrantPermissions        
        if (-not $viAccount) {
              throw "VIAccount with Id '$UserNameToGrantPermissions' not found in domain '$domainAlias'"
        }

        # Add permissions on VMHost
        New-VIPermission -Principal $viAccount -Role $viRole -Entity $vmHostinstance

    } catch {
            Write-Error ("The following error has occurred for VMHost '$vmHostinstance': rn"+$_)
      } finally {
            Disconnect-VIServer $vmHostConnection -Confirm:$false
      }