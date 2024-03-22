<#
.SYNOPSIS
Adds members from one Active Directory group to another Active Directory group.

.DESCRIPTION
The Add-ADGroupMembersToAnotherGroup function adds members from a source Active Directory group to a destination Active Directory group.
It retrieves members from the source group and adds them to the destination group.

.PARAMETER SourceGroupName
Specifies the name of the source Active Directory group from which members will be retrieved.

.PARAMETER DestinationGroupName
Specifies the name of the destination Active Directory group to which members will be added.

.EXAMPLE
Add-ADGroupMembersToAnotherGroup -SourceGroupName "SourceGroup" -DestinationGroupName "DestinationGroup"

This command adds members from the "SourceGroup" to the "DestinationGroup".

#>

function Add-ADGroupMembersToAnotherGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceGroupName,

        [Parameter(Mandatory = $true)]
        [string]$DestinationGroupName
    )

    # Check if Active Directory module is available
    if (-not (Get-Module -Name ActiveDirectory -ErrorAction SilentlyContinue)) {
        Write-Error "Active Directory module is not available. Please install RSAT tools or import the module."
        return
    }

    # Check if the source group exists
    $sourceGroup = Get-ADGroup -Filter { Name -eq $SourceGroupName }
    if (-not $sourceGroup) {
        Write-Error "Source group '$SourceGroupName' not found."
        return
    }

    # Check if the destination group exists
    $destinationGroup = Get-ADGroup -Filter { Name -eq $DestinationGroupName }
    if (-not $destinationGroup) {
        Write-Error "Destination group '$DestinationGroupName' not found."
        return
    }

    # Get members from the source group
    $members = Get-ADGroupMember -Identity $SourceGroupName

    # Add members to the destination group
    foreach ($member in $members) {
        Add-ADGroupMember -Identity $DestinationGroupName -Members $member.distinguishedName
    }

    Write-Output "Members added from '$SourceGroupName' to '$DestinationGroupName'."
}
