<#
.SYNOPSIS
Create a user using an AD account.
.DESCRIPTION
Leverages PSZoom to create a Zoom account from an AD account. This is an example script. Some customization required.
.PARAMETER ADAccount
The active directory account. The information from AD will be used to generate a new Zoom user.
.PARAMETER Action
Specify how to create the new user:
create - User will get an email sent from Zoom. There is a confirmation link in this email. The user will then 
need to use the link to activate their Zoom account. 
The user can then set or change their password.
autoCreate - This action is provided for the enterprise customer who has a managed domain. This feature is 
disabled by default because of the security risk involved in creating a user who does not belong to your domain.
custCreate - This action is provided for API partners only. A user created in this way has no password and 
is not able to log into the Zoom web site or client.
ssoCreate - This action is provided for the enabled “Pre-provisioning SSO User” option. A user created in 
this way has no password. If not a basic user, a personal vanity URL using the user name (no domain) of 
the provisioning email will be generated. If the user name or PMI is invalid or occupied, it will use a random 
number or random personal vanity URL.
.PARAMETER Email
User email address.
.PARAMETER Type
Basic (1)
Pro (2)
Corp (3)
.PARAMETER FirstName
User's first namee: cannot contain more than 5 Chinese words.
.PARAMETER LastName
User's last name: cannot contain more than 5 Chinese words.
.PARAMETER PASSWORD
User password. Only used for the "autoCreate" function. The password has to have a minimum of 8 characters and maximum of 32 characters. 
It must have at least one letter (a, b, c..), at least one number (1, 2, 3...) and include both uppercase and lowercase letters. 
It should not contain only one identical character repeatedly ('11111111' or 'aaaaaaaa') and it cannot contain consecutive 
characters ('12345678' or 'abcdefgh').
.OUTPUTS
An object with the Zoom API response. 
.PARAMETER Pmi
Personal Meeting ID, long, length must be 10.
.PARAMETER UsePmi
Use Personal Meeting ID for instant meetings.
.PARAMETER Language
Language.
.PARAMETER Dept
Department for user profile: use for report.
.PARAMETER VanityName
Personal meeting room name.
.PARAMETER HostKey
Host key. It should be a 6-10 digit number.
.PARAMETER CMSUserId
Kaltura user ID.
.PARAMETER ApiKey
The API key.
.PARAMETER ApiSecret
THe API secret.
.OUTPUTS
No output. Can use Passthru switch to pass UserId to output.
.EXAMPLE
New-CompanyZoomUser rskywalker
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/usercreate
.LINK
https://marketplace.zoom.us/docs/api-reference/zoom-api/users/userupdate

#>

#requires -module PSZoom, ActiveDirectory

$Global:ZoomApiKey = 'Enter_Key_Here'
$Global:ZoomApiSecret = 'Enter_Secret_Here'

function New-CompanyZoomUser {
    [CmdletBinding(DefaultParameterSetName = 'AdAccount')]
    param (
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'AdAccount',
            ValueFromPipeline = $True,
            Position = 0
        )]
        [ValidateLength(1, 128)]
        [string]$AdAccount,

        [Parameter(
            Mandatory = $True,
            ParameterSetName = 'Manual',
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 128)]
        [Alias('EmailAddress')]
        [string]$Email,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('create', 'autoCreate', 'custCreate', 'ssoCreate')]
        [string]$Action = 'ssoCreate',
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateSet('Basic', 'Pro', 'Corp', 1, 2, 3)]
        [string]$Type = 'Pro',
            
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 64)]
        [Alias('first_name', 'givenname')]
        [string]$FirstName,
            
        [Parameter(
            Mandatory = $True, 
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateLength(1, 64)]
        [Alias('last_name', 'surname')]
        [string]$LastName,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [ValidateRange(1000000000, 9999999999)]
        [Alias('OfficePhone')]$Pmi,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [bool]$UsePmi,

            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Timezone,
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [string]$Language,
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Department')]
        [string]$Dept,

        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('host_key')]
        [string]$HostKey,
            
        [Parameter(
            ParameterSetName = 'Manual', 
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('vanity_name')]
        [string]$VanityName,

        [Parameter(
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('group_id', 'group', 'id', 'groupids', 'groups')]
        [string[]]$GroupId,
            
        [Parameter(ParameterSetName = 'AdAccount')]
        [Parameter(ParameterSetName = 'Manual')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,
            
        [Parameter(ParameterSetName = 'AdAccount')]
        [Parameter(ParameterSetName = 'Manual')]
        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'AdAccount') {
            $user = (get-aduser -identity $AdAccount -Properties EmailAddress, Surname, GivenName, OfficePhone, Department, Office)

            $params = @{
                'UsePmi' = $True
            }

            if ($User.EmailAddress) {
                $Email = $User.EmailAddress
                $params.Add('EmailAddress', $Email)
            }

            if ($User.Surname) {
                $params.Add('LastName', $User.Surname)
            }

            if ($User.Surname) {
                $params.Add('FirstName', $User.GivenName)
            }

            if ($User.Department) {
                $params.Add('Dept', $User.Department)
            }

            if ($User.OfficePhone) {
                $Pmi = $User.OfficePhone.substring($User.OfficePhone.Length - 10, $User.OfficePhone.Length - 2)
                $params.Add('Pmi', $Pmi)
            }

            if ($HostKey) {
                $params.Add('HostKey', "$HostKey")
            }
                
            if ($User.Office) {
                $OfficeLocation = switch ($User.Office) {
                    'Republic' { 'Republic Office' }
                    { $_ -like "*Imperial*" } { 'Imperial Office' }
                    { $_ -like "*New York*" } { 'NY Office' }
                    Default { 'Republic Office' }
                }

                $GroupID = ((Get-ZoomGroups) | where-object {$_ -match "$OfficeLocation"}).id

                $params.Add('GroupId', $GroupId)
            }

            if ($ApiKey) {
                $params.Add('ApiKey', $ApiKey)
            }

            if ($ApiKey) {
                $params.Add('ApiSecret', $ApiSecret)
            }
            
            New-CompanyZoomUser @params
        } elseif ($PSCmdlet.ParameterSetName -eq 'Manual') {
            $creds = @{
                ApiKey     = 'ApiKey'
                ApiSecret  = 'ApiSecret'
            }

            #Create new user
            $defaultNewUserParams = @{
                Action    = $Action
                Type      = $Type
                Email     = $Email
            }

            function Remove-NonPsBoundParameters {
                param (
                    $Obj,
                    $Parameters = $PSBoundParameters
                )
          
                process {
                    $NewObj = @{ }
              
                    foreach ($Key in $Obj.Keys) {
                        if ($Parameters.ContainsKey($Obj.$Key) -or -not [string]::IsNullOrWhiteSpace($Obj.Key)) {
                            $Newobj.Add($Key, (get-variable $Obj.$Key).value)
                        }
                    }
              
                    return $NewObj
                }
            }

            $newUserParams = @{
                FirstName = 'FirstName'
                LastName  = 'LastName'
            }

            $newUserParams = Remove-NonPsBoundParameters($newUserParams)

            New-ZoomUser @defaultNewUserParams @newUserParams @creds

            #Update parameters that cant be entered with new user
            $updateParams = @{
                UserId     = 'Email'
                HostKey    = 'HostKey'
                Pmi        = 'Pmi'
                Timezone   = 'Timezone'
                Language   = 'Language'
                Dept       = 'Department'
                VanityName = 'VanityName'
                UsePmi    =  'UsePmi'
            }

            $updateParams = Remove-NonPsBoundParameters($updateParams)
            
            Update-ZoomUser @updateParams @creds
            
            #Add user to group
            if ($GroupId) {
                Add-ZoomGroupMember -groupid $GroupId -MemberEmail $email 
            }

            #Add scheduling permission on behalf of Admin account
            Add-ZoomUserAssistants -UserId $Email -AssistantEmail 'admin@thejedi.com'
        }
    }
}
