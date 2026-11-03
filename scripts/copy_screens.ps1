$src = "stitch_file_based_implementation (1)\stitch_file_based_implementation"
$dst = "figma_screens"

if (!(Test-Path $dst)) {
    New-Item -ItemType Directory -Path $dst | Out-Null
}

$dirs = Get-ChildItem -Path $src -Directory | Where-Object { $_.Name -match '^\d{2}\.' -and $_.Name -notmatch 'motion|tooltip' } | Sort-Object Name

$index = 1
foreach ($d in $dirs) {
    $imgPath = Join-Path $d.FullName "screen.png"
    if (Test-Path $imgPath) {
        $prefix = "{0:D2}" -f $index
        $cleanName = $d.Name -replace '^\d{2}\._?', ''
        $targetFile = "$prefix" + "_" + "$cleanName.png"
        Copy-Item -Path $imgPath -Destination (Join-Path $dst $targetFile) -Force
        Write-Output "Copied $targetFile"
        $index++
    }
}

$total = (Get-ChildItem -Path $dst -Filter "*.png").Count
Write-Output "Total screens in $dst : $total"
