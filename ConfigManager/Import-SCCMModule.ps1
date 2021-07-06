<#
    .DESCRIPTION
    Requires the SCCM PowerShell module to be installed.
#>

function Import-SCCMModule {
    param (
        [string]$SiteServer,
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
    )

    $ModuleLocation = "${Env:ProgramFiles(x86)}\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"

    try {
        Import-Module -Name $ModuleLocation -Global
    } catch {
        throw 'ConfigurationManager module is required but was not found and could not be imported automatically. Import the module manually and try again. The module can be installed from the Software Center. The name of the module is Configuration Manager Library.'
    }
}
