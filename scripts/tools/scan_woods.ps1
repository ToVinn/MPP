Add-Type -AssemblyName System.Drawing

$woodsPath = (Resolve-Path "Model/Hutan/free_pixel_16_woods.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($woodsPath)

Write-Host ("Woods dimensions: " + $bmp.Width + "x" + $bmp.Height)

# Find where non-empty regions are by scanning 16x16 blocks
for ($y = 0; $y -lt $bmp.Height; $y += 16) {
    $rowInfo = ""
    for ($x = 0; $x -lt $bmp.Width; $x += 16) {
        $hasColor = $false
        for ($py = $y; $py -lt [Math]::Min($y + 16, $bmp.Height); $py += 4) {
            for ($px = $x; $px -lt [Math]::Min($x + 16, $bmp.Width); $px += 4) {
                if ($bmp.GetPixel($px, $py).A -gt 20) {
                    $hasColor = $true
                    break
                }
            }
            if ($hasColor) { break }
        }
        $rowInfo += if ($hasColor) { "#" } else { "." }
    }
    Write-Host ("Y=" + ($y.ToString().PadLeft(3)) + ": " + $rowInfo)
}

$bmp.Dispose()

