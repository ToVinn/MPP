Add-Type -AssemblyName System.Drawing

$wtPath = (Resolve-Path "Model/Kuil Kuno/The Myth of Pixel_Water Temple 1.05/Tileset/Tileset_Water_Temple.png").Path
$wt = [System.Drawing.Bitmap]::FromFile($wtPath)
Write-Host "Water Temple size: $($wt.Width) x $($wt.Height)"

# Inspect some 32x32 tiles in Water Temple
# Tileset is 640 x 1216 (20 x 38 tiles of 32x32)
Write-Host "Water Temple grid is 20 tiles wide, 38 tiles tall (32x32 each)"
$wt.Dispose()

$bfPath = (Resolve-Path "Model/Desa/Beginning Fields.png").Path
$bf = [System.Drawing.Bitmap]::FromFile($bfPath)
Write-Host "Beginning Fields size: $($bf.Width) x $($bf.Height)"
# Beginning Fields is 640 x 640 (40 x 40 tiles of 16x16, or 20 x 20 tiles of 32x32)
$bf.Dispose()

