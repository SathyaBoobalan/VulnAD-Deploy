<#
.SYNOPSIS
    VulnAD-Deploy: Automated Vulnerable Active Directory Lab Builder
.DESCRIPTION
    Author: Sathya Boobalan
    This script provisions dummy Organizational Units (OUs), Users, and Groups, 
    and intentionally injects Active Directory misconfigurations for Red Team 
    practice (Kerberoasting, AS-REP Roasting, and weak ACLs).
    
    WARNING: DO NOT RUN THIS IN A PRODUCTION ENVIRONMENT!
#>

# Ensure script is running as Administrator
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Warning "[!] Please run this script as an Administrator."
    Exit
}

# Import Active Directory Module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    Write-Host "[+] ActiveDirectory module loaded successfully." -ForegroundColor Green
} catch {
    Write-Error "[-] Failed to load ActiveDirectory module. Is this a Domain Controller?"
    Exit
}

$DomainRoot = (Get-ADDomain).DistinguishedName
Write-Host "[*] Target Domain: $DomainRoot" -ForegroundColor Cyan

# -------------------------------------------------------------------------
# Phase 1: Build the Structure
# -------------------------------------------------------------------------
Write-Host "[*] Phase 1: Creating Lab OUs..." -ForegroundColor Yellow

$OUNames = @("VulnLab_Users", "VulnLab_ServiceAccounts", "VulnLab_IT_Admins")
foreach ($OU in $OUNames) {
    try {
        New-ADOrganizationalUnit -Name $OU -Path $DomainRoot -ErrorAction SilentlyContinue
        Write-Host "  -> Created OU: $OU" -ForegroundColor Green
    } catch {
        Write-Host "  -> OU $OU already exists." -ForegroundColor Gray
    }
}

# -------------------------------------------------------------------------
# Phase 2: Inject Misconfigurations & Vulnerabilities
# -------------------------------------------------------------------------
Write-Host "[*] Phase 2: Injecting Red Team Vulnerabilities..." -ForegroundColor Yellow

# Vulnerability 1: AS-REP Roasting (User does not require Pre-Authentication)
$WeakPwd1 = ConvertTo-SecureString "Welcome2026!" -AsPlainText -Force
$ASRepUser = "jsmith"
try {
    New-ADUser -Name $ASRepUser -GivenName "John" -Surname "Smith" -SamAccountName $ASRepUser -UserPrincipalName "$ASRepUser@$((Get-ADDomain).Name)" -Path "OU=VulnLab_Users,$DomainRoot" -AccountPassword $WeakPwd1 -Enabled $true
    Set-ADUser -Identity $ASRepUser -DoesNotRequirePreAuth $true
    Write-Host "  [+] Injected AS-REP Roasting Vuln: User '$ASRepUser' (Pre-Auth Disabled)" -ForegroundColor Red
} catch { Write-Host "  [-] Failed or user $ASRepUser exists." -ForegroundColor Gray }

# Vulnerability 2: Kerberoasting (User account with an SPN)
# This allows attackers to request a TGS ticket and crack it offline.
$WeakPwd2 = ConvertTo-SecureString "P@ssw0rd_SQL" -AsPlainText -Force
$SPNUser = "svc_sql"
try {
    New-ADUser -Name $SPNUser -GivenName "SQL" -Surname "Service" -SamAccountName $SPNUser -UserPrincipalName "$SPNUser@$((Get-ADDomain).Name)" -Path "OU=VulnLab_ServiceAccounts,$DomainRoot" -AccountPassword $WeakPwd2 -Enabled $true
    Set-ADUser -Identity $SPNUser -ServicePrincipalNames @{Add="MSSQLSvc/db01.$((Get-ADDomain).Name):1433"}
    Write-Host "  [+] Injected Kerberoasting Vuln: User '$SPNUser' (SPN Assigned)" -ForegroundColor Red
} catch { Write-Host "  [-] Failed or user $SPNUser exists." -ForegroundColor Gray }

# Vulnerability 3: Cleartext Password in Description
$DescUser = "helpdesk_admin"
$WeakPwd3 = ConvertTo-SecureString "Admin123!" -AsPlainText -Force
try {
    New-ADUser -Name $DescUser -SamAccountName $DescUser -Path "OU=VulnLab_IT_Admins,$DomainRoot" -AccountPassword $WeakPwd3 -Enabled $true -Description "Backup admin account. Temp password is Admin123!"
    Write-Host "  [+] Injected OSINT/Enum Vuln: Password exposed in AD Description for '$DescUser'" -ForegroundColor Red
} catch { Write-Host "  [-] Failed or user $DescUser exists." -ForegroundColor Gray }

# -------------------------------------------------------------------------
# Cleanup & Finish
# -------------------------------------------------------------------------
Write-Host "=======================================================" -ForegroundColor Cyan
Write-Host "[✔] Vulnerable AD Environment Deployed Successfully!" -ForegroundColor Green
Write-Host "You can now use Impacket, Rubeus, or BloodHound to test." -ForegroundColor Green
Write-Host "=======================================================" -ForegroundColor Cyan