
<#
    .SYNOPSIS
    Modify the iManage EMMConfig file.

    .DESCRIPTION
    By default, running the function will modify the imEMM.Config file located in %APPDATA%\iManage\configs for
    each user on the local computer. Use the ComputerName parameter to modify these files on a remote computer.

    To modify the %ProgramData% location, use the -ProgramData switch. When using this switch the %APPDATA%
    location(s) will not be modified.

    The config file is only modified if it exists in a given location.

    .PARAMETER ComputerName
    The name of the computer where the imEMMConfig file(s) will be modified. Default is the local computer.

    .PARAMETER ForceFileOnSend
    Disable (0) or Enable (1) the ForceFileOnSend Attribute.

    .PARAMETER ProgramData
    Use this switch to modify the %ProgramData% imEMMConfig file.

    .EXAMPLE
    Set the ForceFileOnSend attribute to 0 (disabled) for every AppData configuration file on the local computer.
    Set-imEMMConfig -ForceFileOnSend 0

    .EXAMPLE
    Set the ForceFileOnSend attribute to 0 (disabled) for every AppData configuration file on a remote computer.
    Set-imEMMConfig -ForceFileOnSend 0

    .EXAMPLE
    Set the local computer's imEMMConfig ProgramData config file ForceFileOnSend attribute to 0 (disabled).
    Set-imEMMConfig -ProgramData -ForceFilOnSend 0
#>

function Set-imEMMConfig {
    [CmdletBinding()]
    param (
        [string[]]$ComputerName = $env:computername,

        [ValidateSet(0, 1)]
        [int]$ForceFileOnSend,

        [switch]$ProgramData = $False
    )

    begin {
        if (-not $PSBoundParameters.ContainsKey('ForceFileOnSend')) {
            Write-Warning 'No parameters provided.'
            break
        }
    }

    process {
        foreach($computer in $ComputerName) {
            $script = {
                if ($ProgramData -eq $True) {
                    $files = get-imEMMConfig -ProgramData
                } else {
                    $files = get-imEMMConfig
                }

                if ($computer -ne $env:computername) {
                    foreach ($file in $files) {
                        if ($Null -ne $using:ForceFileOnSend) {
                            if ($file.config.emm_config.ForceFileOnSend -ne $using:ForceFileOnSend) {
                                $file.config.emm_config.ForceFileOnSend = $using:ForceFileOnSend
                            }
                        }
                    }
                } elseif ($computer -eq $env:computername) {
                    foreach ($file in $files) {
                        if ($Null -ne $ForceFileOnSend) {
                            if ($file.config.emm_config.ForceFileOnSend -ne $ForceFileOnSend) {
                                $file.config.emm_config.ForceFileOnSend = $:ForceFileOnSend
                            }
                        }
                    }
                }

                Set-Content -Path $file.path -Value ($file.config | ConvertTo-Json)
            }

            try {
                if ($computer -eq $env:computername) {
                    $Output = Invoke-Command -ScriptBlock $script
                } else {
                    $Output = Invoke-Command -ComputerName $computer -Scriptblock $script
                }
            } catch {
                Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
            }

            Write-Output $Output
        }
    }
}
