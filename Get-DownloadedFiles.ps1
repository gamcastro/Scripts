cls
Get-ChildItem -File -Path $home\downloads |
Sort-Object -Property CreationTime -Descending |
Format-Table -Property CreationTime,Name -Autosize| 
more