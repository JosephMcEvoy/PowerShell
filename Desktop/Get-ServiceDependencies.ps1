<#
.EXAMPLE
Get-ServiceDependencies -ServiceName 'netlogon'
#>

# Function to retrieve startup dependencies for a service
function Get-ServiceDependencies {
    param(
        [string]$ServiceName
    )

    # Get the service object
    $service = Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $ServiceName}

    if ($service) {
        # Get the service's dependencies
        $dependencies = Get-WmiObject -Query "Associators of {Win32_Service.Name='$ServiceName'} WHERE AssocClass=Win32_DependentService ResultRole=Antecedent" | Select-Object -ExpandProperty Name

        if ($dependencies) {
            Write-Verbose "Dependencies for service '$ServiceName':"
            foreach ($dependency in $dependencies) {
                "$dependency"
            }
        } else {
            Write-Verbose "No dependencies found for service '$ServiceName'."
        }
    } else {
        Write-Verbose "Service '$ServiceName' not found."
    }
}
