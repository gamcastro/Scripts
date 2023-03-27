clear
cd D:\Comum\PowerShell\Scripts
if (Test-Path 'C:\Program Files\Google\Chrome\Application\chrome.exe') {
    New-Alias -Name "ch" -Value "C:\Program Files\Google\Chrome\Application\chrome.exe"
}
if (Test-Path 'C:\Program Files\Microsoft Office\root\Office16\Winword.exe') {
    New-Alias -Name "word" -Value "C:\Program Files\Microsoft Office\root\Office16\Winword.exe"
}

function gotoa {
    Set-Location "$home\documents\PowerShell\Modules\"
}
New-Alias -Name "modulos" -Value gotoa
New-Alias -Name "desligar" -Value Stop-Computer -Force
