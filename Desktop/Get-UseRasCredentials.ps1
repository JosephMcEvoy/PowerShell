
function Get-UseRasCredentials {
      $RasphonePath = Join-Path -Path $env:appdata -ChildPath '\Microsoft\Network\Connections\Pbk\rasphone.pbk'

      if ((Test-Path $RasphonePath) -eq $False) {
          Write-Warning 'Rasphone.pbk not found.'
          Exit 0
      }

      $RasphoneData = (Get-Content $RasphonePath | Select-String UseRasCredentials) | ConvertFrom-StringData
      Write-Output $RasphoneData.UseRASCredentials
}
