<#
.DESCRIPTION
Quick and dirty setting a value in imEMM.config in the current user's app data folder
#>

function Set-ForceFileOnSend {
    param (
        $value = 0
    )

    try {
        $path = "C:\Users\$env:UserName\AppData\Roaming\iManage\Work\Configs\imEMM.config"
        $content = Get-Content $path

        if ($value -eq 0) {
            $content = $content.replace('"ForceFileOnSend":1','"ForceFileOnSend":0')
        } else {
            $content = $content.replace('"ForceFileOnSend":0','"ForceFileOnSend":1')
        }
        $content | Set-Content -Path $path -Force
    } catch {
        $ErrorMessage = $_.Exception.Message 
        Write-Warning $ErrorMessage
        Exit 1
    }
}

Set-ForceFileOnSend -Value 0
