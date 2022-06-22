function Set-NRLOpenMode {
    param (
        [ValidateSet('Edit','Default')]
        [string]$To
    )
    
    function Get-NrlOpenMode {
        try {
            $reg = Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\Nrl\Shell\open\Command" -ErrorAction Stop
        } catch {
            Write-Error $_ 
        }

        Write-Output $reg.'(default)'
    }


    $CurrentValue = Get-NrlOpenMode

    $NewValue = switch ($To) {
        'Edit'  { '"C:\Program Files\iManage\Work\iwlnrl.exe" /F "%1" /EDIT' }
        Default { '"C:\Program Files\iManage\Work\iwlnrl.exe" /F "%1"' }
    }

    if ($CurrentValue -ne $NewValue) {
        New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR | Out-Null
        Set-ItemProperty -Path 'HKCR:\Nrl\Shell\open\Command' -Name '(Default)' -Value $NewValue
    }

    $Output = Get-NrlOpenMode
    Write-Output $Output
}

$Output = Set-NRLOpenMode -To Edit

if ($Output -eq '"C:\Program Files\iManage\Work\iwlnrl.exe" /F "%1" /EDIT') {
    Write-Output "Succesfully set key to $Output."
    Exit 0
} else {
    Write-Output "Failure. Key set to $Output."
    Exit 1
}
