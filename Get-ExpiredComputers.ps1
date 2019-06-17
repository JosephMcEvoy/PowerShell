
<#PSScriptInfo

.VERSION 1.0

.GUID c964bdcb-8e01-429a-86f8-6f121a63d202

.AUTHOR jmcevoy

.COMPANYNAME 

.COPYRIGHT 

.TAGS 

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES


#>

<#
.DESCRIPTION
Retrieves specific information about one or more computers from active directory, 
depending on Operating System and last logon time.

.PARAMETER Day
An integer value to determine how many days since the last logon. Use positive integers.

.PARAMETER OperatingSystem
A string value that filters by operating system.

.PARAMETER Ping
A switch value to determine if the function should ping the computer. Simply add -ping in your command.

.PARAMETER SearchBase
The DC/OU to search.

.EXAMPLE
Get-ExpiredComputers -days 30 -os 'Windows XP*' -SearchBase "OU=COMPUTERS,DC=LAW,DC=FIRM" -ping $false

.EXAMPLE
Get-ExpiredComputers -day 30 -operatingsystem 'Windows XP*' -SearchBase 'OU=Computers,DC=law,DC=firm' | Remove-ADComputer
Finds computers that haven't been logged onto for 30 days then removes them from Active Directory.

.EXAMPLE
Get-ExpiredComputers -days 30 -os 'Windows XP*' | Export-Csv 'ExpiredComputers.csv' -notype
This example will export the results to a CSV.

.EXAMPLE
$job = start-job {Get-ExpiredComputers -days 30 -os 'Windows 7*'}
Wait-Job $job
Receive-Job $job | Export-Csv 'ExpiredComputers.csv' -notype

#>

param()

function Get-ExpiredComputers {
    [CmdletBinding()]
    param (
        [Alias('Days')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$Day = 30,
        [Alias('OS')]
        [string]$OperatingSystem = '*',
        [switch]$Ping,
        [string]$SearchBase
    )
    
    $old = (Get-Date).AddDays(-$Day)

    #Filter computers according to user defined parameters
    Write-Verbose -Message "Finding computers last logged on more than $Day days(s) ago with an operating system that matches '$OperatingSystem'."
    
    $params = @{ }
    
    if ($SearchBase) {
        $params.add('SearchBase', $SearchBase)
    }
    
    $ADComputers = Get-ADComputer -Filter { (lastlogondate -lt $old) -and (operatingsystem -like $OperatingSystem) } @params -Property Name, OperatingSystem, Created, Description, LastLogOndate

    #Generate the object to output
    $ADComputers | ForEach-Object {
        $obj = [PSCustomObject]@{
            'ComputerName'      = $_.Name
            'OSVersion'         = $_.OperatingSystem
            'Created'           = $_.Created
            'Description'       = $_.description
            'Last Log On Date'  = $_.LastLogOnDate
            'Connection Status' =
            #Ping the computer to determine connectivity
            if ($Ping) {
                Write-Verbose "Pinging computer $($_.Name)"
                if (test-connection -count 1 -computername $_.Name -Quiet -ErrorAction SilentlyContinue) {
                    Write-Verbose -message "Connection Succesful"
                    'Connected'
                }
                else {
                    Write-Verbose -message "Connection Unsuccesful"
                    'Disconnected'
                }
            }
            else {
                'Unknown'
            }
        }
        Write-Verbose -Message "Total computers found: $($ADComputers.Count)"
        Write-Output $obj
    }
}
