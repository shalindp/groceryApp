# build-apk-dropbox.ps1
$ProjectDir = "E:\Dev\groceryApp"
$Src = "$ProjectDir\build\app\outputs\flutter-apk\app-release.apk"
$DstDir = "C:\Users\shali\Dropbox\_temp"

$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Dst = "$DstDir\app-release_$Timestamp.apk"

Set-Location $ProjectDir

Write-Host "Building Flutter APK in release mode..."
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Flutter build failed!"
    exit 1
}

# Wait until APK exists
$counter = 0
while (-not (Test-Path $Src) -and $counter -lt 30) {
    Start-Sleep -Seconds 1
    $counter++
}

if (-not (Test-Path $Src)) {
    Write-Host "ERROR: APK not found after 30 seconds!"
    exit 1
}

# Ensure destination folder exists
if (-not (Test-Path $DstDir)) {
    Write-Host "Destination folder missing. Creating..."
    New-Item -ItemType Directory -Path $DstDir | Out-Null
}

# Copy APK
Copy-Item -Path $Src -Destination $Dst -Force
Write-Host "APK copied successfully to $Dst"
