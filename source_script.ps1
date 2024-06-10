<#
.SYNOPSIS
    Script to create and update a dynamic folder for RoyalTS apps that automatically pull targets from Wallix Admin Bastion API.

.DESCRIPTION
    This script is designed to be used as a source script in a RoyalTS dynamic folder. It will query the Wallix Admin Bastion API for session rights and create a RoyalTS JSON payload for each target.

.AUTHOR
    Pierre Martin (@d4hu).

.LICENSE
    GPLv3
#>

# Define variables
$PrimaryUser = "$EffectiveUsername$"     # Primary username
$PrimaryPassword = "$EffectivePassword$" # Primary password
$BastionFQDN = "$CustomField1$"          # Bastion fully qualified domain name

# Create credentials for API auth.
$pair = "$($PrimaryUser):$($PrimaryPassword)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

# Set headers for API auth.
$Headers = @{
    Authorization = $basicAuthValue
}

# Get session rights from Wallix Bastion
$response = Invoke-WebRequest -Uri "https://$BastionFQDN/api/sessionrights" -Headers $Headers -Method Get -ContentType "application/json" -UseBasicParsing

# Convert session rights JSON to PowerShell object
$WallixSessionRights = $response.Content | ConvertFrom-Json

# Create an array to store authorization objects
$MyAuthorization = foreach ($WallixSessionRight in $WallixSessionRights) {
    # Determine the target type based on service protocol
    $TargetType = switch ($WallixSessionRight.service_protocol) {
        "RDP" { "RemoteDesktopConnection" }
        "APP" { "RemoteDesktopConnection" }
        "SSH" { "TerminalConnection" }
    }
    # Determine the target name based on type (device or application)
    $TargetName = switch ($WallixSessionRight.type) {
        "device" { $WallixSessionRight.device }
        "application" { $WallixSessionRight.application }
    }
    # Create a new target object for RoyalTS
    [PSCustomObject]@{
        "Type" = $TargetType
        "Name" = $TargetName
        "ComputerName" = $BastionFQDN
        "Username" = "$($WallixSessionRight.account)@$($WallixSessionRight.domain)@$($TargetName):$($WallixSessionRight.service_protocol):$($WallixSessionRight.authorization):$($PrimaryUser)"
        "Password" = $PrimaryPassword
        "Description" = "$($WallixSessionRight.device_description)$($WallixSessionRight.application_description)"
        "Path" = "$($WallixSessionRight.authorization)"
    }
}

# Convert the MyAuthorization array to JSON
$MyAuthorizationJSON = $MyAuthorization| sort-object -property Path | ConvertTo-Json

# Construct the final JSON payload for RoyalTS
$rJSON = @"
{
    "Objects": $MyAuthorizationJSON
}
"@

# Return the final RoyalJSON payload
$rJSON