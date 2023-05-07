[CmdletBinding()]
Param(
    [string]$Arquivo
)
Clear-Host
Write-Host "                      Controloador Financeiro         "
Write-Host " "
$itensCompra = @()
$fatura = Get-GeoFaturaCartaoCredito -FilePath $Arquivo
$itensCompra += $fatura | Group-Object -Property ItemCompra | ForEach-Object {
    [PSCustomObject]@{
        'Item' = $_.Name
        'Total' = ($_.Group | Measure-Object -Property ValorItem -Sum).Sum
        'QtdCompras' = $_.Count
    }
}
$itensCompra | Sort-Object -Property Total -Descending | 
              Format-Table -Propert @{Name = 'Quantidade de Compras';Expression={$_.QtdCompras};Align='center';Width=15},
                                    @{Name = 'Item';Expression={$_.Item};Align='center';Width=40},
                                    @{Name='Valor Comprado';Expression={$_.Total};Width=10}