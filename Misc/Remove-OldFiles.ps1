<#

    .PARAMETER Path
    The path where the files are to be deleted.

    .PARAMETER Days
    The number of days old a file has to be in order to be removed. Default is 7.

    .PARAMETER FileTypes
    One or more file types to remove. Default is 'log'.

#>

function Remove-OldFiles {
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [int]$Days = 7,

	[string[]]$FileTypes = 'log'
    )

    $FileTypes = $FileTypes | ForEach-Object {
        Write-Output "*.$_"
    }

    $limit = (Get-Date).AddDays(-$Days)

    # Delete files older than the $limit.
    Get-ChildItem -Path $Path -Include $FileTypes -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
}
