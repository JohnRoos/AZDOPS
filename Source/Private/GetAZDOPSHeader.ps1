function GetAZDOPSHeader {
    [CmdletBinding()]
    param (
        [string]$Organization
    )

    try { 
        Get-Variable -Name 'AZDOPSCredentials' -Scope Script -ErrorAction Stop 
    } catch {
        Throw "Headers missing. Use Connect-AZDOPSCredentials to connect."
    }
    
    $Res = @{}
    
    if (-not [string]::IsNullOrEmpty($Organization)) {
        $HeaderObj = $Script:AZDOPSCredentials[$Organization]
        $res.Add('Organization', $Organization)
    }
    else {
        $r = $script:AZDOPSCredentials.Keys | Where-Object {$script:AZDOPSCredentials[$_].Default -eq $true}
        $HeaderObj = $script:AZDOPSCredentials[$r]
        $res.Add('Organization', $r)
    }

    switch ($HeaderObj.Type) {
        'PAT' {
            $UserName = $HeaderObj.Credential.UserName
            $Password = $HeaderObj.Credential.GetNetworkCredential().Password

            $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $UserName, $Password)))
            $Header = @{
                Authorization = ("Basic {0}" -f $base64AuthInfo)
            }
        }
        'OAuth2' {
            $Header = @{
                Authorization = "Bearer {0}" -f $HeaderObj.AccessToken
            }
        }
    }

    $Res.Add('Header',$Header)

    Write-Output -InputObject $Res
}