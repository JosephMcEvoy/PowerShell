function Disable-PhotoViewer {
    param()

    process {
        New-PSDrive -Name "HKR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Write-Verbose
        $RegPath = "HKR:\Applications\photoviewer.dll"

        if (test-path $RegPath) {
                Remove-Item $RegPath -Recurse -Force | Write-Verbose
        }


        #Remove drive
        Remove-PSDrive HKR
    }
}

Disable-PhotoViewer