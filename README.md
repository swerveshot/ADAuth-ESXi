# vSphere AD Authentication lab

![Validate Packer Template](https://github.com/swerveshot/ADAuth-ESXi/workflows/Validate%20Packer%20Template/badge.svg?branch=swerveshot-actions-1)

### Introduction
This is a project to create a virtual lab for testing vSphere AD Authentication for ESXi server.

The goal of this lab is to test if an AD user with the Admin role can perform the same tasks as the root user can. Furthermore there is an IAM user which can be used to administer the root password. This can be used as a service account for systems that programatically change passwords.

The project is based on HashiCorp's Packer and contains a couple of wrapper scripts to get up and running quickly. These wrapper scripts depend on the Packer executable being available through the path environment variable. For Packer to deploy the active directory server an example variables file is included. Rename this file to `ADAuth-DC01-vars.json` and enter the credentials of your choice. If this file is not present the deployment will fail.

When using these scripts use them in the following order:
1. `.\Create-ADAuth-DC01.ps1 .\ADAuth-DC01.json -Verbose`
1. `.\Create-ADAuth-ESXi01.ps1`
1. `.\Set-ESXiADAuth.ps1 -VMHost [IPAddress] -ADServer [IPAddress]`
