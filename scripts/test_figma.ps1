$p = Get-Process -Name "Figma" -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }
if ($p) {
    Write-Output "Found Figma Main Window: ID = $($p.Id), Title = $($p.MainWindowTitle)"
} else {
    Write-Output "No main window handle found on Figma processes"
}
