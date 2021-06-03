<#

    .DESCRIPTION
    Remove .log files from a path recursively that are older than a given number of days.

    .PARAMETER Path
    The path to the files to be deleted.

    .PARAMETER Days
    The number of days old a file has to be in order to be removed.

#>

function Clear-Logs {
    param (
        [Parameter(Mandatory = $True, Position = 0)]
        [string]$Path,

        [Parameter(Position = 1)]
        [int]$Days = 7
    )

    $limit = (Get-Date).AddDays(-$Days)

    # Delete files older than the $limit.
    Get-ChildItem -Path $Path -Include *.log -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
}
