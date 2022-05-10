<#
.DESCRIPTION
Creates three groups and assigns one or more given applications to each group with three intentions: Requires, Uninstall, and Available.
#>

#requires -Modules 'Az.Resources','Microsoft.Graph.Intune'

$prefix = "App-"
$groupDescription = "Automatically generated software deployment group."
$mobileApps = Get-IntuneMobileApp | ? displayname -like "*some app*"

foreach ($mobileApp in $mobileApps) {
    $appName = $mobileApp.groupName.Replace(' ', '_') # Change this if desired.

    $groupNames = @(
        @{
            name = $prefix + $appName + "-Required"
            intent = 'required'
        },
        @{
            name = $prefix + $appName + "-Uninstall"
            intent = 'uninstall'
        },
        @{
            name = $prefix + $appName + "-Available"
            intent = 'available'
        }
    )
    
    foreach ($name in $groupNames) {
        New-AzADGroup -DisplayName $name.name -MailNickname $name.name -Description $groupDescription  -verbose
        $group = (Get-AzADGroup -DisplayName $name.name -verbose)
        $target = New-DeviceAndAppManagementAssignmentTargetObject -groupAssignmentTarget -groupId $group.id  -verbose
        New-IntuneMobileAppAssignment -mobileAppID $mobileApp.id -Intent $name.intent -target $target -Verbose
    }
}
