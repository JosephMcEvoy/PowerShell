function Find-HashDifferencesForLikeKeys {
    <#
        .SYNOPSIS
        Outputs a hashtable of keys/values of the primary hash table that are different from then secondary hash table.
        If the key is not in both hashes then it is ignored.
        
        .DESCRIPTION
        For each key in the primary hash table that has a matching key in the secondary hash table, if the value of the key is different
        for each hash then it is returned in the new hash output.
        
        .PARAMETER Primary
        The authoritative hash source.
        
        .PARAMETER Secondary
        The secondary hash table.
        
        .OUTPUTS
        A hashtable.
        
        .EXAMPLE
        [hashtable]$alpha =@{
            "A1" = "P1"
            "A2" = "P2"
            "A3" = "plane"
            "A4" = "flower"
            "A5" = "dog"
        }
            
            
        [hashtable]$beta =@{
            "A1" = "P1"
            "A2" = "P2"
            "garden" = "p3"
            "flower" = "P4"
            "A5" = "P5"
        }


        Find-HashDifferencesForLikeKeys -Primary $alpha -Secondary $beta

        Outputs:

        Name                           Value
        ----                           -----
        A5                             dog

    #>

    param (
        [hashtable]$Primary,
        [hashtable]$Secondary
    )

    [hashtable]$Output = @{}

    foreach ($key in $Primary.keys) {
        if ($Secondary.$key) {
            if ($Primary.$key -ne $Secondary.$key){
                $Output.Add($key, $Primary.$key)
            }
        }
    }

    Write-Output $Output
}
