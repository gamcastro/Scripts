param(
    [string]$Pasta = "$home\Documents"
)
Get-ChildItem -Directory -Path $Pasta | Format-Wide