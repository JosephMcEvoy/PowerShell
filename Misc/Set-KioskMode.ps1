# Name: MultiKiosk
# Authors: Jörgen Nilsson

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Username,
    [Parameter(Mandatory=$True)]
    [string]$Password
  )

# Set values
$Version="1"
$RegKeyName = "CCMEXECOSD"
$FullRegKeyName = "HKLM:\SOFTWARE\" + $regkeyname 
$Domain="4sysops"

# Create Registry key 
New-Item -Path $FullRegKeyName -type Directory -ErrorAction SilentlyContinue

function Set-KioskMode {

    $DomainUser = "$($Domain)\$($UserName)".TrimStart('\')

    $nameSpaceName="root\cimv2\mdm\dmmap"
    $className="MDM_AssignedAccess"
    $obj = Get-CimInstance -Namespace $namespaceName -ClassName $className
    Add-Type -AssemblyName System.Web
    $obj.Configuration = [System.Web.HttpUtility]::HtmlEncode(@"
    <?xml version="1.0" encoding="utf-8" ?>
    <AssignedAccessConfiguration 
      xmlns="http://schemas.microsoft.com/AssignedAccess/2017/config"
      xmlns:v2="http://schemas.microsoft.com/AssignedAccess/201810/config"
      xmlns:v3="http://schemas.microsoft.com/AssignedAccess/2020/config"
    >
      <Profiles>
        <Profile Id="{9A2A490F-10F6-4764-974A-43B19E722C23}">
          <AllAppsList>
            <AllowedApps>
              <App AppUserModelId="Windows.PrintDialog_cw5n1h2txyewy" />
              <App DesktopAppPath="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" />
              <App DesktopAppPath="C:\Program Files\Microsoft Office\root\Office16\Excel.exe" />
              <App DesktopAppPath="C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" />
            </AllowedApps>
          </AllAppsList>
          <v2:FileExplorerNamespaceRestrictions>
            <v2:AllowedNamespace Name="Downloads"/>
            <v3:AllowRemovableDrives/>
          </v2:FileExplorerNamespaceRestrictions>
          <StartLayout>
            <![CDATA[<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
                          <LayoutOptions StartTileGroupCellWidth="6" />
                          <DefaultLayoutOverride>
                            <StartLayoutCollection>
                              <defaultlayout:StartLayout GroupCellWidth="6">
                                <start:Group Name="Product">
                                  <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Google Chrome.lnk" />
                                  <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" />
                                  <start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Excel.lnk" />
                                </start:Group>
                              </defaultlayout:StartLayout>
                            </StartLayoutCollection>
                          </DefaultLayoutOverride>
                        </LayoutModificationTemplate>
                    ]]>
          </StartLayout>
          <Taskbar ShowTaskbar="true"/>
        </Profile>
      </Profiles>
      <Configs>
        <Config>
          <Account>$DomainUser</Account>
          <DefaultProfile Id="{9A2A490F-10F6-4764-974A-43B19E722C23}"/>
        </Config>
      </Configs>
    </AssignedAccessConfiguration>
"@)
Set-CimInstance -CimInstance $obj
}

$Code = @'
Add-Type @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
 
namespace PInvoke.LSAUtil {
    public class LSAutil {
        [StructLayout (LayoutKind.Sequential)]
        private struct LSA_UNICODE_STRING {
            public UInt16 Length;
            public UInt16 MaximumLength;
            public IntPtr Buffer;
        }
 
        [StructLayout (LayoutKind.Sequential)]
        private struct LSA_OBJECT_ATTRIBUTES {
            public int Length;
            public IntPtr RootDirectory;
            public LSA_UNICODE_STRING ObjectName;
            public uint Attributes;
            public IntPtr SecurityDescriptor;
            public IntPtr SecurityQualityOfService;
        }
 
        private enum LSA_AccessPolicy : long {
            POLICY_VIEW_LOCAL_INFORMATION = 0x00000001L,
            POLICY_VIEW_AUDIT_INFORMATION = 0x00000002L,
            POLICY_GET_PRIVATE_INFORMATION = 0x00000004L,
            POLICY_TRUST_ADMIN = 0x00000008L,
            POLICY_CREATE_ACCOUNT = 0x00000010L,
            POLICY_CREATE_SECRET = 0x00000020L,
            POLICY_CREATE_PRIVILEGE = 0x00000040L,
            POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000080L,
            POLICY_SET_AUDIT_REQUIREMENTS = 0x00000100L,
            POLICY_AUDIT_LOG_ADMIN = 0x00000200L,
            POLICY_SERVER_ADMIN = 0x00000400L,
            POLICY_LOOKUP_NAMES = 0x00000800L,
            POLICY_NOTIFICATION = 0x00001000L
        }
 
        [DllImport ("advapi32.dll", SetLastError = true, PreserveSig = true)]
        private static extern uint LsaStorePrivateData (
            IntPtr policyHandle,
            ref LSA_UNICODE_STRING KeyName,
            ref LSA_UNICODE_STRING PrivateData
        );
 
        [DllImport ("advapi32.dll", SetLastError = true, PreserveSig = true)]
        private static extern uint LsaOpenPolicy (
            ref LSA_UNICODE_STRING SystemName,
            ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
            uint DesiredAccess,
            out IntPtr PolicyHandle
        );
 
        [DllImport ("advapi32.dll", SetLastError = true, PreserveSig = true)]
        private static extern uint LsaNtStatusToWinError (
            uint status
        );
 
        [DllImport ("advapi32.dll", SetLastError = true, PreserveSig = true)]
        private static extern uint LsaClose (
            IntPtr policyHandle
        );
 
        [DllImport ("advapi32.dll", SetLastError = true, PreserveSig = true)]
        private static extern uint LsaFreeMemory (
            IntPtr buffer
        );
 
        private LSA_OBJECT_ATTRIBUTES objectAttributes;
        private LSA_UNICODE_STRING localsystem;
        private LSA_UNICODE_STRING secretName;
 
        public LSAutil (string key) {
            if (key.Length == 0) {
                throw new Exception ("Key lenght zero");
            }
 
            objectAttributes = new LSA_OBJECT_ATTRIBUTES ();
            objectAttributes.Length = 0;
            objectAttributes.RootDirectory = IntPtr.Zero;
            objectAttributes.Attributes = 0;
            objectAttributes.SecurityDescriptor = IntPtr.Zero;
            objectAttributes.SecurityQualityOfService = IntPtr.Zero;
 
            localsystem = new LSA_UNICODE_STRING ();
            localsystem.Buffer = IntPtr.Zero;
            localsystem.Length = 0;
            localsystem.MaximumLength = 0;
 
            secretName = new LSA_UNICODE_STRING ();
            secretName.Buffer = Marshal.StringToHGlobalUni (key);
            secretName.Length = (UInt16) (key.Length * UnicodeEncoding.CharSize);
            secretName.MaximumLength = (UInt16) ((key.Length + 1) * UnicodeEncoding.CharSize);
        }
 
        private IntPtr GetLsaPolicy (LSA_AccessPolicy access) {
            IntPtr LsaPolicyHandle;
            uint ntsResult = LsaOpenPolicy (ref this.localsystem, ref this.objectAttributes, (uint) access, out LsaPolicyHandle);
            uint winErrorCode = LsaNtStatusToWinError (ntsResult);
            if (winErrorCode != 0) {
                throw new Exception ("LsaOpenPolicy failed: " + winErrorCode);
            }
            return LsaPolicyHandle;
        }
 
        private static void ReleaseLsaPolicy (IntPtr LsaPolicyHandle) {
            uint ntsResult = LsaClose (LsaPolicyHandle);
            uint winErrorCode = LsaNtStatusToWinError (ntsResult);
            if (winErrorCode != 0) {
                throw new Exception ("LsaClose failed: " + winErrorCode);
            }
        }
 
        private static void FreeMemory (IntPtr Buffer) {
            uint ntsResult = LsaFreeMemory (Buffer);
            uint winErrorCode = LsaNtStatusToWinError (ntsResult);
            if (winErrorCode != 0) {
                throw new Exception ("LsaFreeMemory failed: " + winErrorCode);
            }
        }
 
        public void SetSecret (string value) {
            LSA_UNICODE_STRING lusSecretData = new LSA_UNICODE_STRING ();
 
            if (value.Length > 0) {
                //Create data and key
                lusSecretData.Buffer = Marshal.StringToHGlobalUni (value);
                lusSecretData.Length = (UInt16) (value.Length * UnicodeEncoding.CharSize);
                lusSecretData.MaximumLength = (UInt16) ((value.Length + 1) * UnicodeEncoding.CharSize);
            } else {
                //Delete data and key
                lusSecretData.Buffer = IntPtr.Zero;
                lusSecretData.Length = 0;
                lusSecretData.MaximumLength = 0;
            }
 
            IntPtr LsaPolicyHandle = GetLsaPolicy (LSA_AccessPolicy.POLICY_CREATE_SECRET);
            uint result = LsaStorePrivateData (LsaPolicyHandle, ref secretName, ref lusSecretData);
            ReleaseLsaPolicy (LsaPolicyHandle);
 
            uint winErrorCode = LsaNtStatusToWinError (result);
            if (winErrorCode != 0) {
                throw new Exception ("StorePrivateData failed: " + winErrorCode);
            }
        }
    }
}
"@
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Value "%USERNAME%"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultDomainName" -Value "%DOMAINNAME%"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "1"
[PInvoke.LSAUtil.LSAutil]::new("DefaultPassword").SetSecret("%PASSWORD%")
Unregister-ScheduledTask -TaskName "CreateAutologon" -Confirm:$false -EA SilentlyContinue
Restart-Computer -Force
'@

function Create-Task ($Argument)
{

    $Schedule = New-Object -ComObject "Schedule.Service"
    $Schedule.Connect('localhost')
    $Folder = $Schedule.GetFolder('\')

    $task = $Schedule.NewTask(0)
    $task.RegistrationInfo.Author = "Onevinn"
    $task.RegistrationInfo.Description = "CreateAutologon"

    $action = $task.Actions.Create(0)
    $action.Path = "PowerShell.exe"
    $action.Arguments = "$Argument"

    $task.Settings.StartWhenAvailable = $true

    $trigger = $task.Triggers.Create(8)
    $trigger.Delay = "PT120S"


    $result = $Folder.RegisterTaskDefinition("CreateAutologon", $task, 0, "SYSTEM", $null, 5)
}

$Code = $Code.Replace("%USERNAME%", $Username)
$Code = $Code.Replace("%DOMAINNAME%", $Domain)
$Code = $Code.Replace("%PASSWORD%", $Password)

$bytes = [System.Text.Encoding]::Unicode.GetBytes($Code)
$b64 = [System.Convert]::ToBase64String($bytes)

Set-KioskMode

Create-Task -Argument "-EncodedCommand $($b64)"

# Set registry values to be used later
new-itemproperty $FullRegKeyName -Name "Kiosk Version" -Value $Version -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
new-itemproperty $FullRegKeyName -Name "UserName" -Value $username -Type STRING -Force -ErrorAction SilentlyContinue | Out-Null
