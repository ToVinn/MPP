Add-Type -AssemblyName System.Drawing

$bfPath = (Resolve-Path "Model/Desa/Beginning Fields.png").Path
$bf = [System.Drawing.Bitmap]::FromFile($bfPath)

# Beginning Fields is 640x640 (tiles are 16x16 or 32x32)
# Let's inspect colors of 16x16 tiles across first 10 columns and 10 rows
for ($r = 0; $r -lt 10; $r++) {
    $line = "Row $r : "
    for ($c = 0; $c -lt 10; $c++) {
        $px = $bf.GetPixel($c * 16 + 8, $r * 16 + 8)
        $rVal = $px.R
        $gVal = $px.G
        $bVal = $px.B
        if ($gVal -gt $rVal -and $gVal -gt $bVal) {
            $line += "GRASS "
        } elseif ($rVal -gt 150 -and $gVal -gt 130 -and $bVal -lt 120) {
            $line += "DIRT  "
        } elseif ($bVal -gt $rVal -and $bVal -gt $gVal) {
            $line += "WATER "
        } else {
            $line += "STONE "
        }
    }
    Write-Host $line
}

$bf.Dispose()

