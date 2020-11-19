

function Remove-ZoomClient {
    param(
        $Confirm = $False
    )

    [System.Collections.ArrayList]$UserArray = (Get-ChildItem C:\Users).Name 
    $UserArray.Remove('Public') #Public folder does not install apps.

    New-PSDrive HKU Registry HKEY_USERS 
    
    foreach ($obj in $UserArray){
        $Parent = "$env:SystemDrive\users\$obj\Appdata\Roaming" 
        $Path = Test-Path -Path (Join-Path $Parent 'zoom\uninstall') 
        if ($Path) {
            Write-Verbose "Zoom is installed for user $obj" 
            $User = New-Object System.Security.Principal.NTAccount($obj) 
            $sid = $User.Translate([System.Security.Principal.SecurityIdentifier]).value 
    
            if (test-path "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\ZoomUMX") {
                Write-Verbose "Removing registry key ZoomUMX for $sid on HK_Users" 
                Remove-Item "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Uninstall\ZoomUMX" -Force 
            } 
    
            Write-Verbose "Removing folder on $Parent" 
            Remove-item -Recurse -Path (join-path $Parent 'zoom') -Force -Confirm:$Confirm
    
            Write-Verbose "Removing start menu shortcut" 
            Remove-item -Rrecurse -Path (Join-Path $Parent '\Microsoft\Windows\Start Menu\Programs\zoom') -Force -Confirm:$Confirm
        } else {
            Write-Verbose "Zoom is not installed for user $obj"
        }
    } 
    
    Remove-PSDrive HKU
}

Remove-ZoomClient -Verbose