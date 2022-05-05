function Get-AzureLocalComputerAdministratorSIDs(){
	Write-Output @(([ADSI]::new("WinNT://$($env:COMPUTERNAME)/$((New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")).Translate([System.Security.Principal.NTAccount]).Value.Split("\")[1]),Group")).Invoke('Members') | ForEach-Object {$((New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList @([Byte[]](([ADSI]$_).properties.objectSid).Value, 0)).Value)})
}
