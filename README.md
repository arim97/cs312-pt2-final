# Automatic Minecraft Server Hosting on EC2 (Windows 11)

This repository provides all the resources needed to automatically perform the steps needed 

**Requirements:**

- An AWS Account

- Basic AWS and Powershell knowledge (Preferred)

- Windows 11
- Terraform ver 1.13
- Windows PowerShell
- AWS CLI


## Overview

We are going to be using Terraform to provision our EC2 resources and run the scrips required to start and host our minecraft server

## Tutorial

#### Step. 1 - Installing Chocolatey 

The simplest way to install terraform and set the proper paths is through the package manager Chocolatey. To install Chocolatey, inn a PowerShell window enter the following command

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
#### Step. 2 - Installing Terraform
In a PowerShell window enter the following command (You might need to close and reopen PowerShel for it to recognize Chocolatey)

```
choco install terraform
```
#### Step. 3 - Installing AWS CLI and setting up credentials 
To install AWS CLI enter the following command, enter the following command
```
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```
We need to set the AWS Credentials so that Terraform can perform that tasks required, we will need to acquire those credentials and save them in the file 
~/.aws/credentials.


#### Step. 4 - Starting and running the server

**Make sure you are on a fresh clone of the lates version of this repo, the commands listed below are written accordingly**

All the scripts needed are already coded into the .tf file. In your PowerShell Window, navigate to the terraform directory
```
cd ../terraform
```
Then, enter the command

```
terraform init
```

followed by

```
terraform apply
```

When prompted, confirm the changes by entering "yes".

And we are finished! Allow a few minutes for the instance to initialize, which after you can connect freshly started server with the public IP address that Terraform printed as output
  
## Sources

### [Setting up a Minecraft Java server on Amazon EC2](https://aws.amazon.com/blogs/gametech/setting-up-a-minecraft-java-server-on-amazon-ec2/)
### OSU CS312 Lab 9 Instructions