<#

.DESCRIPTION
Creates three groups for one or more given applications. 
Creates three assignments for the application(s) to the respective group and intent.

#>

#requires -Modules 'Az.Resources','Microsoft.Graph.Intune'

$prefix = "App-"
$groupDescription = "Automatically generated software deployment group."
$mobileApps = Get-IntuneMobileApp

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
