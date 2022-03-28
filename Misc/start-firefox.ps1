function start-firefox {
    [cmdletbinding()]
    param (
        [Parameter(ValueFromPipeline = $True)]
        [string[]]$url,

        [string]$path = 'C:\Program Files\Mozilla Firefox\firefox.exe'
    )

    foreach ($u in $url) {
        Start-Process $path -argumentlist "-url $u"
    }

}
