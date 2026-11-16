Add-Type -AssemblyName System.Drawing

function Crop-Image([string]$srcPath, [string]$destPath, [int]$x, [int]$y, [int]$w, [int]$h) {
    $resolvedSrc = (Resolve-Path $srcPath).Path
    $src = [System.Drawing.Bitmap]::FromFile($resolvedSrc)
    $dest = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
    $srcRect = New-Object System.Drawing.Rectangle($x, $y, $w, $h)
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $w, $h)
    $g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    $dest.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $dest.Dispose()
    $src.Dispose()
    Write-Host ("Saved " + $destPath + " (" + $w + "x" + $h + ")")
}

# 1. Cave Floor & Walls from Water Temple
$waterTemple = "Model/Kuil Kuno/The Myth of Pixel_Water Temple 1.05/Tileset/Tileset_Water_Temple.png"
Crop-Image $waterTemple "assets/textures/cave_floor_stone.png" 0 256 64 64
Crop-Image $waterTemple "assets/textures/cave_wall_cliff.png" 0 0 192 128
Crop-Image $waterTemple "assets/textures/cave_wall_rim.png" 0 128 192 64
Crop-Image $waterTemple "assets/textures/cave_water_deep.png" 256 0 128 128
Crop-Image $waterTemple "assets/textures/cave_stone_bridge.png" 192 192 64 64

# 2. Forest & Village from Beginning Fields
$begFields = "Model/Desa/Beginning Fields.png"
Crop-Image $begFields "assets/textures/forest_grass.png" 0 0 64 64
Crop-Image $begFields "assets/textures/forest_dirt_path.png" 64 0 64 64
Crop-Image $begFields "assets/textures/village_cobble.png" 128 0 64 64
Crop-Image $begFields "assets/textures/village_fence.png" 320 0 64 64

# 3. Temple from Knowledge Temple
$ktFloor = "Model/Kuil Kuno/KNOWLEDGE TEMPLE/Terrain/Floor Patterns.png"
Crop-Image $ktFloor "assets/textures/temple_floor_star.png" 0 0 64 64
Crop-Image $ktFloor "assets/textures/temple_floor_paver.png" 64 0 64 64

$ktWalls = "Model/Kuil Kuno/KNOWLEDGE TEMPLE/Walls/Walls.png"
Crop-Image $ktWalls "assets/textures/temple_wall_marble.png" 0 0 128 128

Write-Host "All texture slices created successfully!"

