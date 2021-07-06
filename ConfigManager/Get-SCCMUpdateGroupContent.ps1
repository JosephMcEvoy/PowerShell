<#

.Synopsis
Lists assigned software updates in a configuration manager 2012 software update group
.DESCRIPTION
Lists all assigned software updates in a configuration manager 2012 software update group that is selected 
from the list of available update groups or provided as a command line option
.EXAMPLE
Get-SCCMUpdateGroupContent
.EXAMPLE
Get-SCCMUpdateGroupContent -UpdateGroup 'PatchMyPC Update Groups 2021-05-03 00:02:00'

#>
 
function Get-SCCMUpdateGroupContent {
    [CmdletBinding()]
    param(
        # Software Update Group
        [Parameter(Mandatory = $False, ValueFromPipeline = $true)]
        [String]$Name
    )
    
    $Group = Get-CMSoftwareUpdateGroup -Name $Name  | Select-Object LocalizedDisplayName 
 
    $info = @()
 
    foreach ($item in $Group) {
        Write-Verbose "Processing Software Update Group $($item.LocalizedDisplayName)"
        forEach ($item1 in (Get-CMSoftwareUpdate -UpdateGroupName $($item.LocalizedDisplayName) -Fast)) {
            $object = New-Object -TypeName PSObject
            #$object | Add-Member -MemberType NoteProperty -Name UpdateGroup -Value $item.LocalizedDisplayName
            $object | Add-Member -MemberType NoteProperty -Name ArticleID -Value $item1.ArticleID
            $object | Add-Member -MemberType NoteProperty -Name BulletinID -Value $item1.BulletinID
            $object | Add-Member -MemberType NoteProperty -Name Title -Value $item1.LocalizedDisplayName
            $info += $object
        }
    }

    Write-Output $info
}
