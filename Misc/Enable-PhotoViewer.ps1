function Enable-PhotoViewer {
    param()

    process {
        New-PSDrive -Name "HKR" -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" | Write-Verbose
        $RegPath = "HKR:\Applications\photoviewer.dll"
        
        #Create registry keys
        $keys = @("$RegPath", "$RegPath\shell", "$RegPath\shell\open", "$RegPath\shell\open\DropTarget", "$RegPath\shell\open\command", "$RegPath\shell\print", "$RegPath\shell\print\command", "$RegPath\shell\print\DropTarget")
        
        $keys | ForEach-Object {
            if (-not (test-path $_)) {
                New-Item $_ | Write-Verbose
            }
        }
        
        #Create key properties
        $param1 = @{
            Path         = "$RegPath\shell\open"
            Name         = 'MuiVerb'
            Value        = '@photoviewer.dll,-3043'
            PropertyType = 'String'
        }
        
        $param2 = @{
            Path         = "$RegPath\shell\open\command"
            Name         = '(Default)'
            Value        = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'
            PropertyType = 'ExpandString'
        }

        $param3 = @{
            Path         = "$RegPath\shell\open\DropTarget"
            Name         = 'Clsid'
            Value        = '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}'
            PropertyType = 'String'
        }

        $param4 = @{
            Path         = "$RegPath\shell\print\DropTarget"
            Name         = 'Clsid'
            Value        = '{60fd46de-f830-4894-a628-6fa81bc0190d}'
            PropertyType = 'String'
        }
        
        $param5 = @{
            Path         = "$RegPath\shell\print\command"
            Name         = '(Default)'
            Value        = '%SystemRoot%\System32\rundll32.exe "%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll", ImageView_Fullscreen %1'
            PropertyType = 'ExpandString'
        }
        
        $params = @($param1, $param2, $param3, $param4, $param5)
        
        foreach ($parameter in $params) { 
            if (-not (get-itemproperty -path $parameter.path -name $parameter.name -ErrorAction SilentlyContinue)."$($parameter.name)") {
                New-ItemProperty @parameter | Write-Verbose
            } else {
                Remove-ItemProperty -path $parameter.path -name $parameter.name | Write-Verbose
                New-ItemProperty @parameter | Write-Verbose
            }
        }
        
        #Remove drive
        Remove-PSDrive HKR
    }
}

Enable-PhotoViewer