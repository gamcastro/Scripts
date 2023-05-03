[CmdletBinding()]
param(
    [string]$Arquivo,

    [string[]]$Tipo
)
Clear-Host
Write-Host "                   Listando Valores Contidos na Fatura do [Mês] - [Ano]"
Write-Host "-------------------------------------------------------------------------------------"
Write-Host ""

$ret = Get-GeoFaturaCartaoCredito -FilePath $Arquivo -Filter $Tipo 
$ret | Format-Table @{Name = 'Categoria'; Expression = { $_.Categoria }; Width = 40 },
@{Name = 'Valor'; Expression = { $_.'Valor Total' }; Width = 30; align = 'left'; formatstring = 'c' }

Write-Host ""                    
Write-Host "-------------------------------------------------------------------------------------"
$ret | Measure-Object -Property 'Valor Total' -Sum | Format-Table @{Name='Total Geral';Expression={$_.SUM};align='right';formatstring='c';width=50}