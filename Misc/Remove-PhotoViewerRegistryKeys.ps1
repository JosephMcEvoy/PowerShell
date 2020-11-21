function Remove-PhotoViewerRegistryKeys {
    param()

    process {
        New-PSDrive -Name "HKR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT"
        $RegPath = "HKR:\Applications\photoviewer.dll"

        if (test-path $RegPath) {
                Remove-Item $RegPath -Recurse -Force
        }


        #Remove drive
        Remove-PSDrive HKR
    }
}

Remove-PhotoViewerRegistryKeys
