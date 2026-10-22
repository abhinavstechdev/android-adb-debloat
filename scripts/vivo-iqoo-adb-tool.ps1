# Android ADB Debloat - conservative interactive tool
# Windows PowerShell 5.1+ / PowerShell 7+. No root required.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
function Invoke-Adb {
    param([Parameter(Mandatory=$true)][string[]]$Arguments)
    $output = & adb @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "ADB failed (exit $LASTEXITCODE): adb $($Arguments -join ' ') $([Environment]::NewLine)$($output -join [Environment]::NewLine)" }
    return $output
}
function Test-AdbReady {
    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) { throw "adb not found. Install Google's Android SDK Platform-Tools or add adb to PATH." }
    $devices = Invoke-Adb -Arguments @('devices')
    $ready = @($devices | Where-Object { $_ -match "^\S+\s+device$" })
    if ($ready.Count -ne 1) { Write-Host ($devices -join [Environment]::NewLine); throw "Expected exactly one authorized device. Check USB debugging/RSA prompt and disconnect other devices." }
    return $ready[0].Split([char]9)[0]
}
function Get-DeviceContext {
    $keys = @('ro.product.manufacturer','ro.product.brand','ro.product.model','ro.product.device','ro.build.version.release','ro.build.version.sdk','ro.build.display.id','ro.vivo.os.version','ro.build.version.ota')
    $info = [ordered]@{}
    foreach ($key in $keys) { try { $info[$key] = (Invoke-Adb -Arguments @('shell','getprop',$key) | Out-String).Trim() } catch { $info[$key] = '' } }
    return $info
}
function Get-PackageInventory {
    $all = Invoke-Adb -Arguments @('shell','pm','list','packages')
    $third = Invoke-Adb -Arguments @('shell','pm','list','packages','-3')
    $disabled = Invoke-Adb -Arguments @('shell','pm','list','packages','-d')
    return [pscustomobject]@{
        All = @($all | ForEach-Object { ($_ -replace '^package:', '').Trim() } | Where-Object { $_ })
        ThirdParty = @($third | ForEach-Object { ($_ -replace '^package:', '').Trim() } | Where-Object { $_ })
        Disabled = @($disabled | ForEach-Object { ($_ -replace '^package:', '').Trim() } | Where-Object { $_ })
    }
}
function Save-Audit {
    $folder = Join-Path (Get-Location) ("adb-audit-" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    New-Item -ItemType Directory -Path $folder | Out-Null
    $device = Get-DeviceContext
    $inventory = Get-PackageInventory
    $device | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 (Join-Path $folder 'device-context.json')
    $inventory.All | Sort-Object | Set-Content -Encoding UTF8 (Join-Path $folder 'all-packages.txt')
    $inventory.ThirdParty | Sort-Object | Set-Content -Encoding UTF8 (Join-Path $folder 'third-party-packages.txt')
    $inventory.Disabled | Sort-Object | Set-Content -Encoding UTF8 (Join-Path $folder 'disabled-packages.txt')
    Invoke-Adb -Arguments @('shell','pm','list','packages','-f') | Set-Content -Encoding UTF8 (Join-Path $folder 'packages-with-paths.txt')
    Invoke-Adb -Arguments @('shell','dumpsys','package') | Set-Content -Encoding UTF8 (Join-Path $folder 'package-dump.txt')
    Write-Host "Audit saved to: $folder" -ForegroundColor Green
    Write-Host 'Audit files may contain device/app metadata; review before sharing.'
}
$criticalPattern = '(?i)(^android$|systemui|settings|permissioncontroller|packageinstaller|package.?manager|telephony|telecom|phone|emergency|biometric|keyguard|launcher|inputmethod|webview|google\.android\.gms|vivo\.rom|vivo\.system|iqoo\.rom)'
function Confirm-PackageAction {
    param([Parameter(Mandatory=$true)][string]$Package,[Parameter(Mandatory=$true)][ValidateSet('disable','enable','uninstall','restore')][string]$Action)
    if ($Package -notmatch '^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+$') { throw "Invalid package identifier: $Package" }
    if ($Action -in @('disable','uninstall') -and $Package -match $criticalPattern) { throw "Safety stop: '$Package' resembles a critical component." }
    Write-Host "Target: $Package | Action: $Action" -ForegroundColor Yellow
    Write-Host 'This script cannot prove that a package is safe for your exact firmware.'
    $expected = "YES $Action $Package"
    if ((Read-Host "Type exactly: $expected") -cne $expected) { Write-Host 'Cancelled; no change made.'; return $false }
    return $true
}
try {
    $serial = Test-AdbReady
    Write-Host "Authorized device: $serial" -ForegroundColor Green
    $device = Get-DeviceContext
    $device.GetEnumerator() | ForEach-Object { '{0}: {1}' -f $_.Key, $_.Value } | Write-Host
    while ($true) {
        Write-Host @"
=== Android ADB Debloat ===
1. Create read-only audit (recommended first)
2. List third-party apps
3. Disable one package
4. Re-enable one disabled package
5. Uninstall one package for Android user 0 (higher risk)
6. Restore a user-0 uninstalled package if available
0. Exit
"@
        $choice = Read-Host 'Choose an option'
        try {
            switch ($choice) {
                '1' { Save-Audit }
                '2' { $inv = Get-PackageInventory; $inv.ThirdParty | Sort-Object | ForEach-Object { Write-Host $_ }; Write-Host "Count: $($inv.ThirdParty.Count)" }
                '3' { $pkg = (Read-Host 'Exact package ID to disable').Trim(); if (Confirm-PackageAction -Package $pkg -Action 'disable') { Invoke-Adb -Arguments @('shell','pm','disable-user','--user','0',$pkg) | Write-Host; Write-Host 'Verify phone features before another change.' } }
                '4' { $pkg = (Read-Host 'Exact package ID to enable').Trim(); if (Confirm-PackageAction -Package $pkg -Action 'enable') { Invoke-Adb -Arguments @('shell','pm','enable',$pkg) | Write-Host } }
                '5' { Write-Warning 'User-level uninstall is more disruptive than disabling.'; $pkg = (Read-Host 'Exact package ID to uninstall for user 0').Trim(); if (Confirm-PackageAction -Package $pkg -Action 'uninstall') { Invoke-Adb -Arguments @('shell','pm','uninstall','-k','--user','0',$pkg) | Write-Host } }
                '6' { $pkg = (Read-Host 'Exact package ID to restore').Trim(); if (Confirm-PackageAction -Package $pkg -Action 'restore') { Invoke-Adb -Arguments @('shell','pm','install-existing','--user','0',$pkg) | Write-Host } }
                '0' { break }
                default { Write-Host 'Unknown option.' }
            }
        } catch { Write-Host "Operation failed: $($_.Exception.Message)" -ForegroundColor Red }
        if ($choice -eq '0') { break }
    }
} catch { Write-Error $_; exit 1 }
