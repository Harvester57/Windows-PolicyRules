<#
.SYNOPSIS
Merge Policy Analyzer "PolicyRules" files into one PolicyRules set, written to the pipeline.

.DESCRIPTION
Merge Policy Analyzer "PolicyRules" files into one PolicyRules set, written to the pipeline.

.EXAMPLE
Merge three PolicyRules files into wksta-merged.PolicyRules

Merge-PolicyRules.ps1 .\wksta-basic.PolicyRules .\wksta-kiosk.PolicyRules .\Office.PolicyRules | Out-File -Encoding utf8 -FilePath .\wksta-merged.PolicyRules

.EXAMPLE
Merge all PolicyRules files in the current directory into AllOfThem.PolicyRules

Merge-PolicyRules.ps1 (Get-ChildItem *.PolicyRules) | Out-File -Encoding utf8 -FilePath .\AllOfThem.PolicyRules
#>

param(
    [parameter(Mandatory=$true)]
    [String[]]
    $FilePaths,

    [Parameter(ValueFromRemainingArguments = $true)]
    #[String[]]
    $AdditionalFiles
)

"<PolicyRules>"

foreach( $file in $FilePaths)
{
    Write-Host "Merging $file ..." -ForegroundColor Cyan
    ([xml](Get-Content $file)).DocumentElement.InnerXml
}

foreach( $file in $AdditionalFiles)
{
    Write-Host "Merging $file ..." -ForegroundColor Cyan
    ([xml](Get-Content $file)).DocumentElement.InnerXml
}

"</PolicyRules>"

