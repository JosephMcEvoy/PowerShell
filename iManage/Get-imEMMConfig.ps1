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
            $Users = Get-ChildItem C:\Users

            foreach($User in $Users) {
                $path = "C:\Users\$User\AppData\Roaming\iManage\Work\Configs\imEMM.config"

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
    } else {
        $script = {
            $path = "C:\ProgramData\iManage\AgentServices\configs\imEMM.config"

            if (test-path $path) {
                $config = Get-Content $path
                $Output = @{
                    path   = $path
                    config = $config
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
    } catch {
        Write-Error -Message "$($_.Exception.Message)" -ErrorId $_.Exception.Code -Category InvalidOperation
    }

    Write-Output $Output
}
