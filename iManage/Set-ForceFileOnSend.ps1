try {
    $path = "C:\Users\$env:UserName\AppData\Roaming\iManage\Work\Configs\imEMM.config"
    $content = Get-Content $path 
    $content = $content.replace('"ForceFileOnSend":1','"ForceFileOnSend":0')
    $content | Set-Content -Path $path -Force
} catch {
    $ErrorMessage = $_.Exception.Message 
    Write-Warning $ErrorMessage
    Exit 1
}
