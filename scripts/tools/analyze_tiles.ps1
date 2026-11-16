Add-Type -AssemblyName System.Drawing

function Analyze-Tiles([string]$path, [int]$tileSize) {
    $bmp = [System.Drawing.Bitmap]::FromFile((Resolve-Path $path).Path)
    Write-Host "Analyzing $path ($($bmp.Width)x$($bmp.Height)) with tile size $tileSize..."
    
    $cols = [int]($bmp.Width / $tileSize)
    $rows = [int]($bmp.Height / $tileSize)
    
    for ($r = 0; $r -lt [Math]::Min($rows, 20); $r++) {
        $rowDesc = "R$($r.ToString().PadLeft(2)): "
        for ($c = 0; $c -lt [Math]::Min($cols, 10); $c++) {
            $x = $c * $tileSize
            $y = $r * $tileSize
            # Sample center pixel
            $px = $bmp.GetPixel($x + [int]($tileSize/2), $y + [int]($tileSize/2))
            if ($px.A -lt 10) {
                $rowDesc += "  _  "
            } else {
                $brightness = [int](($px.R + $px.G + $px.B) / 3)
                $rowDesc += "$($brightness.ToString().PadLeft(3)) "
            }
        }
        Write-Host $rowDesc
    }
    $bmp.Dispose()
}

Analyze-Tiles "Model/Kuil Kuno/The Myth of Pixel_Water Temple 1.05/Tileset/Tileset_Water_Temple.png" 32
Analyze-Tiles "Model/Desa/Beginning Fields.png" 32

