Add-Type -AssemblyName System.Drawing

$woodsPath = (Resolve-Path "Model/Hutan/free_pixel_16_woods.png").Path
$bmp = [System.Drawing.Bitmap]::FromFile($woodsPath)

function Crop-Exact($x, $y, $w, $h, $dest) {
    $outBmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($outBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $srcRect = New-Object System.Drawing.Rectangle($x, $y, $w, $h)
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
    $g.DrawImage($bmp, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $outBmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $outBmp.Dispose()
    Write-Host ("Cropped $dest from ($x,$y,$w,$h)")
}

# Big tree: X=16, Y=16, W=80, H=80
Crop-Exact 16 16 80 80 "assets/textures/tree_big.png"
# Pine / Small Tree: X=112, Y=16, W=64, H=80
Crop-Exact 112 16 64 80 "assets/textures/tree_pine.png"
# Boulder: X=16, Y=96, W=48, H=48
Crop-Exact 16 96 48 48 "assets/textures/prop_rock_boulder.png"
# Small Rock 1: X=64, Y=96, W=32, H=32
Crop-Exact 64 96 32 32 "assets/textures/prop_rock_1.png"
# Small Rock 2: X=96, Y=96, W=32, H=32
Crop-Exact 96 96 32 32 "assets/textures/prop_rock_2.png"
# Grass tile: X=16, Y=144, W=32, H=32
Crop-Exact 16 144 32 32 "assets/textures/tile_grass.png"

$bmp.Dispose()
Write-Host "Re-cropped tree and props accurately!"

