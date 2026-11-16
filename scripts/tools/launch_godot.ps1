# Portable Godot Launcher Helper
$projectDir = (Get-Item "$PSScriptRoot\..\..").FullName

$godotExe = $null
$candidates = Get-ChildItem -Path @($projectDir, "$projectDir\..", "$env:USERPROFILE\Downloads") -Filter "Godot*.exe" -Recurse -Depth 2 -ErrorAction SilentlyContinue
if ($candidates) {
    $godotExe = $candidates[0].FullName
}

if (-not $godotExe) {
    $pathCmd = Get-Command "godot" -ErrorAction SilentlyContinue
    if ($pathCmd) { $godotExe = $pathCmd.Source }
}

if ($godotExe) {
    $wshell = New-Object -ComObject WScript.Shell
    $cmd = """$godotExe"" --path ""$projectDir"""
    $wshell.Run($cmd, 1, $false)
    Start-Sleep -Seconds 2
    Get-Process -Name "Godot*" -ErrorAction SilentlyContinue | Select-Object Id, ProcessName, Responding
} else {
    Write-Warning "Godot executable not found."
}
