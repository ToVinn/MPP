Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.SendKeys] | Out-Null

$godotProc = Get-Process -Name "Godot*" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $godotProc) {
    Write-Host "No Godot process running"
    exit 1
}

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }
}
"@

$rect = New-Object Win32+RECT
[Win32]::GetWindowRect($godotProc.MainWindowHandle, [ref]$rect)

$w = $rect.Right - $rect.Left
$h = $rect.Bottom - $rect.Top

Write-Host "Window bounds: Left=$($rect.Left), Top=$($rect.Top), W=$w, H=$h"

if ($w -le 0 -or $h -le 0) {
    $w = 1280
    $h = 720
    $bmp = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen(0, 0, 0, 0, $bmp.Size)
    $outPath = "C:\Users\TEFA RPL\.gemini\antigravity\brain\7d597f71-131e-4855-ba8c-58563b996eaa\current_screen.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Saved full screenshot to $outPath"
} else {
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($rect.Left, $rect.Top, 0, 0, [System.Drawing.Size]::new($w, $h))
    $outPath = "C:\Users\TEFA RPL\.gemini\antigravity\brain\7d597f71-131e-4855-ba8c-58563b996eaa\current_screen.png"
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Saved window screenshot to $outPath"
}

