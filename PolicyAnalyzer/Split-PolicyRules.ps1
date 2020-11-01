<#
.SYNOPSIS
Split one Policy Analyzer "PolicyRules" files into separate files - one output file per GPO.

.DESCRIPTION
Split one Policy Analyzer "PolicyRules" files into separate files - one output file per GPO.

.PARAMETER infile
Path to the input PolicyRules file

.PARAMETER basename
Path and base name of results files - GPO name appended to base name

.EXAMPLE
Split-PolicyRules.ps1 .\Contoso-combined.PolicyRules .\Contoso
#>

param(
    [parameter(Mandatory=$true)]
    [String]
    $infile,

    [parameter(Mandatory=$true)]
    [String]
    $basename
)

# Hash table with GPO names as keys, associated nodes as values.
# No policy name most likely a CSE. Use empty string as policy name
$gpoBuckets = @{}
$xpr = [xml](Get-Content $infile)
$xpr.DocumentElement.ChildNodes | %{
    $item = $_
    $xitem = $_.OuterXml
    $polName = $_.PolicyName
    if ($null -eq $polName) { $polName = "" }
    if ($gpoBuckets.ContainsKey($polName))
    {
        $gpoBuckets[$polName] += $xitem.ToString()
    }
    else
    {
        $gpoBuckets.Add($polName, $xitem.ToString())
    }
}

# GPO names used in filenames. Replace any characters in GPO names that aren't valid in filenames with "~".
# (Limit filtering just to printable ASCII characters.)
$aInvalidChars = ([System.IO.Path]::GetInvalidFileNameChars() | Where-Object { 32 -le [int]$_ -and [int]$_ -le 127 })
$filter = "[" + [RegEx]::Escape($aInvalidChars -join "") + "]"

$gpoBuckets.Keys | %{
    $key = $_
    if ($key.Length -gt 0)
    {
        # Replace invalid characters with ~
        $sGpoFiltered = [RegEx]::Replace($key, $filter, "~")
        $filename = $basename + "-" + $sGpoFiltered + ".PolicyRules"
    }
    else
    {
        # No GPO name. CSEs or just no policy name
        $filename = $basename + "_CSEs_or_NoPolicyName.PolicyRules"
    }
    $filename
    "<PolicyRules>" + $gpoBuckets[$key] + "</PolicyRules>" | Out-File -Encoding utf8 -FilePath $filename
}
