using namespace System.Runtime.InteropServices

[CmdletBinding()]
param(
    [Parameter(Mandatory=$True)]
    [string]$KeyPath,

    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\RegMon-$(Get-Date -Format 'yyyyMMdd-hhmmss').log",

    [Parameter()]
    [int]$Timeout = 0xFFFFFFFF #INFINITE
)
$signature = @'
using System;
using System.Runtime.InteropServices;

namespace Win32
{
    public class Regmon
    {
        [DllImport("Advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int RegOpenKeyExW(
            int hKey,
            string lpSubKey,
            int ulOptions,
            uint samDesired,
            out IntPtr phkResult
        );

        [DllImport("Advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int RegNotifyChangeKeyValue(
            IntPtr hKey,
            bool bWatchSubtree,
            int dwNotifyFilter,
            IntPtr hEvent,
            bool fAsynchronous
        );

        [DllImport("Advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int RegCloseKey(IntPtr hKey);

        [DllImport("Advapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int CloseHandle(IntPtr hKey);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern IntPtr CreateEventW(
            int lpEventAttributes,
            bool bManualReset,
            bool bInitialState,
            string lpName
        );

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int WaitForSingleObject(
            IntPtr hHandle,
            int dwMilliseconds
        );
    }
}
'@
Add-Type -TypeDefinition $signature

if(!(Test-Path $KeyPath)){
    throw "RegistryKey not found."
} 

switch -Wildcard ((Get-Item $KeyPath).Name){
    'HKEY_CLASSES_ROOT*' {$regdefault = 0x80000000 }
    'HKEY_CURRENT_USER*' {$regdefault = 0x80000001}
    'HKEY_LOCAL_MACHINE*' {$regdefault = 0x80000002}
    'HKEY_USERS*' {$regdefault=0x80000003}
    Default {throw 'Unsuported hive.'}
}

$handle = [IntPtr]::Zero
$result = [Win32.Regmon]::RegOpenKeyExW($regdefault,($KeyPath -replace '^.*:\\'),0,0x0010,[ref]$handle)
$event = [Win32.Regmon]::CreateEventW($null,$true,$false,$null)

<#
This will run indefinitely until it fails or reaches a timeout.
Adjust accordingly.
#>
:Outer while ($true) {
    $result = [Win32.Regmon]::RegNotifyChangeKeyValue(
        $handle,
        $false,
        0x00000001L -bor #REG_NOTIFY_CHANGE_NAME
        0x00000002L -bor #REG_NOTIFY_CHANGE_ATTRIBUTES
        0x00000004L -bor #REG_NOTIFY_CHANGE_LAST_SET
        0x00000008L, #REG_NOTIFY_CHANGE_SECURITY
        $event,
        $true
    )
    $wait = [Win32.Regmon]::WaitForSingleObject($event,$Timeout)

    switch ($wait){
        0xFFFFFFFF { break Outer } #WAIT_FAILED
        0x00000102L { #WAIT_TIMEOUT
            $outp = 'Timeout reached.'
            Write-Host $outp -ForegroundColor DarkGreen
            Add-Content -FilePath $LogPath -Value $outp
            break Outer
        }
        0 { #WAIT_OBJECT_0 ~> Change detected.
            $outp = "Change triggered on the specified key. Timestamp: $(Get-Date -Format 'hh:mm:ss - dd/MM/yyyy')."
            Write-Host $outp -ForegroundColor DarkGreen
            Add-Content -FilePath $LogPath -Value $outp
        }
    }

}
[Win32.Regmon]::CloseHandle($event)
[Win32.Regmon]::RegCloseKey($handle)
