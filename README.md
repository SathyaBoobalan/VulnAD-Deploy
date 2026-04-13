# VulnAD-Deploy: Active Directory Vulnerability Injector

**Author:** Sathya Boobalan  
**Role:** System Administrator & Penetration Tester

## Overview
As a System Administrator, I understand that deploying realistic Active Directory labs for Penetration Testing practice can be time-consuming. **VulnAD-Deploy** is a PowerShell-based Infrastructure-as-Code (IaC) script designed to automate the creation of a local Red Team testing environment. 

Instead of manually configuring vulnerabilities, this script takes a vanilla Windows Server Domain Controller and automatically injects advanced misconfigurations, allowing security engineers to practice harvesting tickets, pivoting, and escalating privileges.

## Features & Injected Vulnerabilities
This script automatically provisions OUs, Users, and the following specific attack vectors:
1. **Kerberoasting:** Provisions a service account (`svc_sql`) and assigns a Service Principal Name (SPN), allowing attackers to request and crack TGS tickets offline.
2. **AS-REP Roasting:** Creates a user account with `DONT_REQ_PREAUTH` enabled, allowing attackers to harvest TGT hashes without a password.
3. **Information Disclosure:** Simulates poor SysAdmin practices by leaving cleartext credentials inside Active Directory description fields.

## Prerequisites
* A Virtual Machine running Windows Server (2016/2019/2022).
* Active Directory Domain Services (AD DS) installed and promoted to a Domain Controller.
* PowerShell run as **Administrator**.

## Usage
**WARNING: NEVER RUN THIS SCRIPT IN A PRODUCTION ENVIRONMENT. IT WILL INTENTIONALLY MAKE YOUR NETWORK VULNERABLE.**

1. Clone the repository onto your Domain Controller VM:
\`\`\`powershell
git clone https://github.com/your_github_username/VulnAD-Deploy.git
cd VulnAD-Deploy
\`\`\`

2. Bypass the execution policy (if restricted) and run the deployer:
\`\`\`powershell
Set-ExecutionPolicy Bypass -Scope Process
.\VulnAD-Deploy.ps1
\`\`\`

3. Boot up Kali Linux, fire up `Impacket` or `Rubeus`, and start hacking your new lab!

## Motivation
This project bridges my daily experience in enterprise IT infrastructure with my focus on offensive security. By understanding exactly how Active Directory is built and configured, I can more effectively identify and exploit its weaknesses during VAPT engagements.
