param (
    [Parameter(Mandatory)]
    [string] $Files,

    [Parameter(Mandatory)]
    [string] $LogFile,

    [Parameter(Mandatory)]
    [string] $Version,

    [Parameter()]
    [string] $Includes,

    [Parameter()]
    [string] $SyntaxOnly
)

# Get the verbose switch
$verbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent

# Create the download URL for MetaEditor
$url = "http://www.rosasurfer.com/.mt4/{0}/metaeditor.exe" -f $Version
$exePath = "metaeditor.exe"
if ($verbose) {
    Write-Host "Attempting download from $($url)..."
}

# Attempt to download the metaeditor instance from our URL; if this fails then log the error
try {
    Invoke-WebRequest -Uri $url -OutFile $exePath
} catch {
    if ($verbose) {
        Write-Error "Failed to download MetaEditor from $($url), error: $($_.Exception.Message)"
    }
}

# Create our new list of arguments and add the portable flag to it
$args = New-Object System.Collections.Generic.List[string]
$args.Add("/portable")
$args.Add('/compile:"{0}"' -f $Files)
$args.Add('/inc:"{0}"' -f $Includes)
$args.Add('/log:"{0}"' -f $LogFile)

# If we want to check syntax only then add that flag to the arguments as well
if ([System.Convert]::ToBoolean($SyntaxOnly)) {
    $args.Add("/s")
}

if ($verbose) {
    Write-Host "Calling $($exePath) $($args -join " ")..."
}

# Finally, run metaeditor with our list of arguments
Start-Process $exePath -ArgumentList $args