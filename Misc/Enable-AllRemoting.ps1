#Set active connections to Private
$connectedInterfaces = Get-Netconnectionprofile | where-object {$_.Name -eq "law.firm"} | where-object {$_.NetworkCategory -eq "Public"}
Foreach ($interface in $connectedInterfaces) {
    Set-NetConnectionProfile -InterfaceIndex $interface.interfaceindex -networkcategory Private
}

#PSRemoting and Firewall rules
Enable-PSRemoting
Enable-NetFirewallRule -Name FPS-ICMP4-ERQ-In #enable pinging ipv4
Enable-NetFirewallRule -Name FPS-ICMP6-ERQ-In #enable pinging ipv6
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0 #enable Remote Desktop connections
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" #add firewall rule for Remote Desktop

#Enables Powershell Remoting via IP (As opposed to host name)
$DNSServer = "10.100.18.11"
New-NetFirewallRule -DisplayName “Windows Remote Management (HTTPS-In)” -Name “Windows Remote Management (HTTPS-In)” -Profile Any -LocalPort 5986 -Protocol TCP
New-NetFirewallRule -DisplayName “RemotePowerShell” -Direction Inbound –LocalPort 5985-5986 -Protocol TCP -Action Allow
New-SelfSignedCertificate -DnsName $DNSServer -CertStoreLocation Cert:\LocalMachine\My
$thumbprint = get-childitem Microsoft.PowerShell.Security\Certificate::LocalMachine\My | where-object {$_.Subject -like "CN=" + $DNSServer} | select-object -property Thumbprint 
$thumbprint = $thumbprint -replace "@{Thumbprint=" -replace "}"
new-wsmaninstance winrm/config/listener -SelectorSet @{address="*";Transport="HTTPS"} -ValueSet @{Hostname=$DNSServer;CertificateThumbprint=$thumbprint}
