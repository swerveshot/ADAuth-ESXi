# Set name
$ESXiName = "ADAuth-ESXi01"
Write-Output "***** Deploying nested ESXi server"
Start-Process "${Env:ProgramFiles}\VMware\VMware OVF Tool\ovftool.exe" -ArgumentList "--name=ADAuth-ESXi01 --net:`"VM Network=NAT`" --acceptAllEulas --allowAllExtraConfig `"$env:USERPROFILE\Downloads\Nested_ESXi6.7u3_Appliance_Template_v1.ova`" `"$env:USERPROFILE\Documents\Virtual Machines`"" -Wait -NoNewWindow
# Start-Process "${Env:ProgramFiles(x86)}\VMware\VMware OVF Tool\ovftool.exe" -ArgumentList '--name=Veeam-v10-ESXi --net:"VM Network=NAT" --acceptAllEulas --allowAllExtraConfig "https://download3.vmware.com/software/vmw-tools/nested-esxi/Nested_ESXi6.7u3_Appliance_Template_v1.ova" "$env:USERPROFILE\Documents\Virtual Machines"' -Wait -NoNewWindow

Write-Output "***** Guest customization nested ESXi server"
Add-Content "$env:USERPROFILE\Documents\Virtual Machines\ADAuth-ESXi01\ADAuth-ESXi01.vmx" "guestinfo.createvmfs = `"True`""
# Add-Content "$env:USERPROFILE\Documents\Virtual Machines\ADAuth-ESXi01\ADAuth-ESXi01.vmx" "guestinfo.hostname = `"adauth-esxi01.initiqlabs.local`""
# Add-Content "$env:USERPROFILE\Documents\Virtual Machines\ADAuth-ESXi01\ADAuth-ESXi01.vmx" "guestinfo.domain = `"initiqlabs.local`""

Write-Output "***** Starting nested ESXi server"
Start-Process "${Env:ProgramFiles(x86)}\VMware\VMware Workstation\vmrun" -ArgumentList "-T ws start `"$env:USERPROFILE\Documents\Virtual Machines\ADAuth-ESXi01\ADAuth-ESXi01.vmx`"" -Wait -NoNewWindow