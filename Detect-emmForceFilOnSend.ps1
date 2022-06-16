function Get-imEMMConfig {
    [CmdletBinding()]
    param (
        [string]$ComputerName = $env:computername,

        [Parameter(
            ParameterSetName = 'ProgramData'
        )]
        [switch]$ProgramData
    )

    if (-not $ProgramData) {
        $script = {
            $path = "C:\Users\$env:UserName\AppData\Roaming\iManage\Work\Configs\imEMM.config"

            if (test-path $path) {
                $Config = (Get-Content $path -Raw)

                $Output = @{
                    path   = $path
                    config = $config | ConvertFrom-Json
                }

                Write-Output $output
            }
        }
    }

    try {
        if ($ComputerName -eq $env:computername) {
            $Output = Invoke-Command -ScriptBlock $script
        }
        else {
            $Output = Invoke-Command -ComputerName $ComputerName -Scriptblock $script
        }
    }
    catch {
        Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
    }

    Write-Output $Output
}

try {
    $value = 0
    $path = "C:\Users\$env:UserName\AppData\Roaming\iManage\Work\Configs\imEMM.config"

    if ((Test-Path $path) -eq $False){
        "The file imEMM.config was not found."
        Exit 0
    }

    $imEMMConfig = get-imEMMConfig
    $ForceFileOnSendValue = $imEMMConfig.config.emm_config.ForceFileOnSend

    if ($ForceFileOnSendValue -ne $value) {
        Write-Verbose "ForceFileOnSend not set to $value."
        Exit 1
    } else { 
        Write-Verbose "ForceFileOnSend set to $value."
        Exit 0
    }
} catch {
    $ErrorMessage = $_.Exception.Message 
    Write-Warning $ErrorMessage
    Exit 1
}
