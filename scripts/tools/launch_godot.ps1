$wshell = New-Object -ComObject WScript.Shell
$cmd = '"""C:\Users\TEFA RPL\Downloads\kvin\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe""" --path """C:\Users\TEFA RPL\Downloads\kvin\game MPP"""'
$wshell.Run($cmd, 1, $false)
Start-Sleep -Seconds 2
Get-Process -Name "Godot*" | Select-Object Id, ProcessName, Responding
