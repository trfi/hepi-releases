$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$repo = 'trfi/hepi-releases'
$dest = if ($env:HEPI_DIR) { $env:HEPI_DIR } else { Join-Path $env:LOCALAPPDATA 'Hepi' }
$api = if ($env:HEPI_VERSION) {
    "https://api.github.com/repos/$repo/releases/tags/v$($env:HEPI_VERSION)"
} else {
    "https://api.github.com/repos/$repo/releases/latest"
}

$release = Invoke-RestMethod $api -Headers @{ 'User-Agent' = 'hepi-installer' }
$asset = $release.assets | Where-Object { $_.name -like '*x64-portable.zip' } | Select-Object -First 1
if (-not $asset) { throw "No portable package found in release $($release.tag_name)." }

$zip = Join-Path $env:TEMP $asset.name
Write-Host "Downloading Hepi $($release.tag_name)..."
Invoke-WebRequest $asset.browser_download_url -OutFile $zip

Write-Host "Extracting to $dest ..."
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip -Force

Write-Host "Done. Hepi is installed at: $dest" -ForegroundColor Green
Invoke-Item $dest
