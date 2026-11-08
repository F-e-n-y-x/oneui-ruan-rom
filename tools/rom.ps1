# Downloads the release named in release.txt, checks its SHA-256, unpacks it and runs its install or
# update script. Run through ..\install.bat or ..\update.bat. Interrupted downloads resume on the next run.
param([Parameter(Mandatory)][ValidateSet('install', 'update')][string]$Mode)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot)
$tag = (Get-Content release.txt -TotalCount 1).Trim()
$name = "OneUI8.5-ruan-$tag"
# Assets through the API: github.com/.../releases/download links of this repo time out (504) at times.
$api = "https://api.github.com/repos/F-e-n-y-x/oneui-ruan-rom/releases"
function Get-Asset($url, $out, [switch]$Resume) {
    $c = @('-fL', '--retry', '5', '-H', 'Accept: application/octet-stream', '-o', $out)
    if ($Resume) { $c += @('-C', '-') }
    curl.exe @c $url
    if ($LASTEXITCODE) { throw "Download of $out failed: run again to resume" }
}

New-Item -ItemType Directory -Force download | Out-Null
Set-Location download
if (-not (Test-Path "$name\$Mode.bat")) {
    $z = @("$env:ProgramFiles\7-Zip\7z.exe", "${env:ProgramFiles(x86)}\7-Zip\7z.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $z) { throw "7-Zip not found: install it from https://www.7-zip.org and run again" }
    Write-Host "Downloading $name (about 5 GB, needs about 13 GB free while unpacking)"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $assets = (Invoke-RestMethod "$api/tags/$tag").assets
    $url = @{}; foreach ($a in $assets) { $url[$a.name] = $a.url }
    Get-Asset $url["$name.7z.sha256"] "$name.7z.sha256"
    $files = @($assets.name | Where-Object { $_ -like "$name.7z.0*" } | Sort-Object)
    if (-not $files) { throw "Release $tag has no $name.7z parts" }
    foreach ($f in $files) {
        if (Test-Path $f) { continue }
        Get-Asset $url[$f] "$f.part" -Resume
        Move-Item "$f.part" $f
    }
    Write-Host "Checking the download..."
    $sha = [Security.Cryptography.SHA256]::Create()
    $buf = New-Object byte[] (4MB)
    foreach ($f in $files) {
        $s = [IO.File]::OpenRead((Resolve-Path $f).Path)
        while (($n = $s.Read($buf, 0, $buf.Length)) -gt 0) { [void]$sha.TransformBlock($buf, 0, $n, $null, 0) }
        $s.Close()
    }
    [void]$sha.TransformFinalBlock($buf, 0, 0)
    $got = -join ($sha.Hash | ForEach-Object { $_.ToString('x2') })
    if ($got -ne (Get-Content "$name.7z.sha256").Split(' ')[0]) {
        throw "The download is damaged: delete the download folder and run again"
    }
    & $z x -y $files[0]
    if ($LASTEXITCODE) { throw "7-Zip could not unpack the download" }
    Remove-Item $files   # 5 GB back; the unpacked folder is kept for later runs
}
Set-Location $name
cmd /c "$Mode.bat"
