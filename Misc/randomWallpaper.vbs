'Run this in Windows task scheduler to deploy the sript silently.
command = "%systemroot%\System32\WindowsPowerShell\V1.0\PowerShell.exe -NoLogo -NonInteractive -NoProfile -ExecutionPolicy Bypass -File C:\Users\Default\Scripts\randomWallpaper.ps1"
set shell = CreateObject("WScript.Shell")
shell.Run command,0