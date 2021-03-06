<#
    .DESCRIPTION
    Connections to SCCM site. Requires the SCCM PowerShell module.
#>

function Connect-SCCM {
    param (
        [string]$SiteCode# = 'Define company SiteCode (e.g. DB1)',
        [string]$SiteServer# = 'Define Company FQDN of SCCM Server here (e.g. sccmserver01.star.wars)',
        [string]$Description = 'Primary site',
        [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty,
        $ModuleLocation = "${Env:ProgramFiles(x86)}\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"
    )

    if (Get-PSDrive -Name $SiteCode -ErrorAction SilentlyContinue) {
        Write-Verbose "$SiteCode drive already intialized. Setting location to $SiteCode."
        Set-Location "$($SiteCode):"
        break
    }

    if (-not (Get-Module 'ConfigurationManager' -ErrorAction SilentlyContinue)){
        Import-SCCMModule #Import-Module -Name $ModuleLocation -ErrorAction SilentlyContinue -Scope Global
    }

    if (-not (Get-Module 'ConfigurationManager')){
        throw 'Unable to import ConfigurationManager module. Try importing manually.'
    }

    if ($Credential -eq [System.Management.Automation.PSCredential]::Empty) {
        $Credential = Get-Credential
    }

    New-PSDrive -Name $SiteCode -PSProvider "AdminUI.PS.Provider\CMSite" -Root $SiteServer -Description $Description -credential $Credential -Scope Global

    Set-Location "$($SiteCode):"
}
