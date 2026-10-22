# Android ADB Debloat - conservative interactive tool
# Focused on Vivo & iQOO devices. Windows PowerShell 5.1+ / PowerShell 7+. No root required.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Adb {
    param([Parameter(Mandatory=$true)][string[]]$Arguments)
    $output = & adb @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { 
        throw "ADB failed (exit $LASTEXITCODE): adb $($Arguments -join ' ') $([Environment]::NewLine)$($output -join [Environment]::NewLine)" 
    }
    return $output
}

function Test-AdbReady {
    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) { 
        throw "adb not found. Install Google's Android SDK Platform-Tools or add adb to PATH." 
    }
    $devices = Invoke-Adb -Arguments @('devices')
    $ready = @($devices | Where-Object { $_ -match "^\S+\s+device$" })
    if ($ready.Count -ne 1) { 
        Write-Host ($devices -join [Environment]::NewLine)
        throw "Expected exactly one authorized device. Check USB debugging/RSA prompt and disconnect other devices." 
    }
    return $ready[0].Split([char]9)[0]
}

function Get-DeviceContext {
    $keys = @('ro.product.manufacturer','ro.product.brand','ro.product.model','ro.product.device','ro.build.version.release','ro.build.version.sdk','ro.build.display.id','ro.vivo.os.version','ro.build.version.ota')
    $info = [ordered]@{}
    foreach ($key in $keys) { 
        try { 
            $info[$key] = (Invoke-Adb -Arguments @('shell','getprop',$key) | Out-String).Trim() 
        } catch { 
            $info[$key] = '' 
        } 
    }
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
    Write-Host 'Audit files contain device and package metadata; review before sharing.'
}

# Critical pattern guardrail: protect core telephony, UI, system navigators, storage provider, and security center
$criticalPattern = '(?i)(^android$|systemui|settings|permissioncontroller|packageinstaller|package.?manager|telephony|telecom|phone|emergency|biometric|keyguard|launcher|inputmethod|webview|google\.android\.gms|vivo\.rom|vivo\.system|iqoo\.rom|documentsui|upslide|safecenter|imanager)'

function Confirm-PackageAction {
    param(
        [Parameter(Mandatory=$true)][string]$Package,
        [Parameter(Mandatory=$true)][ValidateSet('disable','enable','uninstall','restore')][string]$Action
    )
    if ($Package -notmatch '^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+$') { 
        throw "Invalid package identifier format: $Package" 
    }
    if ($Action -in @('disable','uninstall') -and $Package -match $criticalPattern) { 
        throw "Safety guardrail triggered: '$Package' matches a protected system component (Launcher, Gesture Navigation, Document Picker, Security Center, Telephony, or GMS). Action blocked." 
    }
    Write-Host "Target: $Package | Action: $Action" -ForegroundColor Yellow
    Write-Host 'Notice: This tool cannot guarantee that removal is safe for your specific firmware build.' -ForegroundColor DarkYellow
    $expected = "YES $Action $Package"
    $response = Read-Host "Type exactly '$expected' to confirm"
    if ($response -cne $expected) { 
        Write-Host 'Operation cancelled; no changes were made.' -ForegroundColor Cyan
        return $false 
    }
    return $true
}

function Show-PackageDetails {
    param([Parameter(Mandatory=$true)][string]$Package)
    if ($Package -notmatch '^[A-Za-z0-9_]+(\.[A-Za-z0-9_]+)+$') { 
        throw "Invalid package identifier format: $Package" 
    }
    Write-Host "=== Inspecting Package: $Package ===" -ForegroundColor Cyan
    try {
        $path = Invoke-Adb -Arguments @('shell','pm','path',$Package)
        Write-Host "APK Location: $path"
    } catch {
        Write-Host "Package not found or not installed on device." -ForegroundColor Yellow
        return
    }
    $disabledList = Invoke-Adb -Arguments @('shell','pm','list','packages','-d')
    $isDisabled = ($disabledList -match [regex]::Escape("package:$Package"))
    if ($isDisabled) {
        Write-Host "Current State: DISABLED" -ForegroundColor Yellow
    } else {
        Write-Host "Current State: ENABLED" -ForegroundColor Green
    }
    Write-Host "Fetching package dump summary (version, installer, flags)..."
    try {
        $dump = Invoke-Adb -Arguments @('shell','dumpsys','package',$Package)
        $dump | Select-String -Pattern 'versionName|versionCode|installerPackageName|flags=\[' | Select-Object -First 10 | ForEach-Object { Write-Host "  $_" }
    } catch {
        Write-Host "Could not fetch dumpsys info."
    }
}

function Search-Packages {
    param([Parameter(Mandatory=$true)][string]$Keyword)
    $inv = Get-PackageInventory
    $matches = @($inv.All | Where-Object { $_ -match [regex]::Escape($Keyword) })
    Write-Host "Found $($matches.Count) packages matching '$Keyword':" -ForegroundColor Cyan
    foreach ($m in $matches) {
        $flag = if ($inv.Disabled -contains $m) { "[DISABLED]" } elseif ($inv.ThirdParty -contains $m) { "[3RD-PARTY]" } else { "[SYSTEM]" }
        Write-Host "  $flag $m"
    }
}

function Handle-PackageError {
    param([System.Exception]$Exception)
    $msg = $Exception.Message
    if ($msg -match 'DELETE_FAILED_USER_RESTRICTED') {
        Write-Host "[!] OEM RESTRICTION: Vivo / Funtouch OS blocked uninstallation of this package (DELETE_FAILED_USER_RESTRICTED)." -ForegroundColor Red
        Write-Host "    Vivo has protected this package in its enterprise policy. Try disabling it instead (Option 3), or manage its permissions via Settings." -ForegroundColor Yellow
        Write-Host "    See research/xda-vivo-iqoo.md for technical background." -ForegroundColor DarkGray
    } elseif ($msg -match 'Cannot disable a protected package') {
        Write-Host "[!] SECURITY EXCEPTION: Android kernel refuses to disable this protected package." -ForegroundColor Red
        Write-Host "    This package is marked as critical by the OEM firmware. Do not attempt forceful workarounds." -ForegroundColor Yellow
    } else {
        Write-Host "Operation failed: $msg" -ForegroundColor Red
    }
}

try {
    $serial = Test-AdbReady
    Write-Host "Authorized device connected: $serial" -ForegroundColor Green
    $device = Get-DeviceContext
    $device.GetEnumerator() | ForEach-Object { '{0}: {1}' -f $_.Key, $_.Value } | Write-Host
    while ($true) {
        Write-Host @"

=== Android ADB Debloat Tool ===
1. Create read-only audit snapshot (Recommended first)
2. List third-party packages (-3)
3. Disable one package (Reversible first experiment)
4. Re-enable one disabled package
5. Uninstall one package for user 0 (Higher risk)
6. Restore a user-0 uninstalled package (install-existing)
7. Inspect package details and status
8. Search packages by keyword
0. Exit
"@
        $choice = Read-Host 'Choose an option [0-8]'
        try {
            switch ($choice) {
                '1' { Save-Audit }
                '2' { 
                    $inv = Get-PackageInventory
                    $inv.ThirdParty | Sort-Object | ForEach-Object { Write-Host $_ }
                    Write-Host "Total third-party packages: $($inv.ThirdParty.Count)" -ForegroundColor Cyan
                }
                '3' { 
                    $pkg = (Read-Host 'Exact package ID to disable').Trim()
                    if (Confirm-PackageAction -Package $pkg -Action 'disable') { 
                        Invoke-Adb -Arguments @('shell','pm','disable-user','--user','0',$pkg) | Write-Host
                        Write-Host 'Package disabled. Reboot phone and test core features before making another change.' -ForegroundColor Green
                    } 
                }
                '4' { 
                    $pkg = (Read-Host 'Exact package ID to enable').Trim()
                    if (Confirm-PackageAction -Package $pkg -Action 'enable') { 
                        Invoke-Adb -Arguments @('shell','pm','enable',$pkg) | Write-Host
                        Write-Host 'Package enabled.' -ForegroundColor Green
                    } 
                }
                '5' { 
                    Write-Warning 'User-0 uninstall is more disruptive than disabling. Prefer disabling (Option 3) first.'
                    $pkg = (Read-Host 'Exact package ID to uninstall for user 0').Trim()
                    if (Confirm-PackageAction -Package $pkg -Action 'uninstall') { 
                        Invoke-Adb -Arguments @('shell','pm','uninstall','-k','--user','0',$pkg) | Write-Host
                        Write-Host 'Package uninstalled for user 0. Verify phone functionality.' -ForegroundColor Green
                    } 
                }
                '6' { 
                    $pkg = (Read-Host 'Exact package ID to restore').Trim()
                    if (Confirm-PackageAction -Package $pkg -Action 'restore') { 
                        Invoke-Adb -Arguments @('shell','cmd','package','install-existing','--user','0',$pkg) | Write-Host
                        Write-Host 'Package restored.' -ForegroundColor Green
                    } 
                }
                '7' {
                    $pkg = (Read-Host 'Exact package ID to inspect').Trim()
                    Show-PackageDetails -Package $pkg
                }
                '8' {
                    $kw = (Read-Host 'Enter keyword to search (e.g. browser, cloud, vivo, facebook)').Trim()
                    Search-Packages -Keyword $kw
                }
                '0' { break }
                default { Write-Host 'Unknown option. Please choose 0 to 8.' -ForegroundColor Yellow }
            }
        } catch { 
            Handle-PackageError -Exception $_.Exception
        }
        if ($choice -eq '0') { break }
    }
} catch { 
    Write-Error $_
    exit 1 
}
