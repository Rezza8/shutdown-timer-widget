Add-Type -AssemblyName System.Drawing

# Load the PNG
$png = [System.Drawing.Image]::FromFile('D:\OPENAI\shutdown timer widget\ShutdownWidget\icon.png')

# Create ICO with multiple sizes
$iconSizes = @(16, 24, 32, 48, 64, 128, 256)
$iconDir = "D:\OPENAI\shutdown timer widget\ShutdownWidget\icon.ico"

# Use a memory stream to build ICO
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms

# ICO header
$bw.Write([ushort]0)   # Reserved
$bw.Write([ushort]1)   # Type (1 = ICO)
$bw.Write([ushort]$iconSizes.Count)  # Number of images

$imageOffset = 6 + $iconSizes.Count * 16  # Header + directory entries

foreach ($size in $iconSizes) {
    # Create resized bitmap
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($png, 0, 0, $size, $size)
    $g.Dispose()

    # Save as PNG to memory stream
    $pngMs = New-Object System.IO.MemoryStream
    $bmp.Save($pngMs, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngBytes = $pngMs.ToArray()
    $pngMs.Dispose()
    $bmp.Dispose()

    # Directory entry
    $bw.Write([byte]$size)      # Width (0 = 256)
    $bw.Write([byte]$size)      # Height (0 = 256)
    $bw.Write([byte]0)          # Color count
    $bw.Write([byte]0)          # Reserved
    $bw.Write([ushort]0)        # Color planes
    $bw.Write([ushort]32)       # Bits per pixel
    $bw.Write([uint]$pngBytes.Length)  # Size in bytes
    $bw.Write([uint]$imageOffset)      # Offset
    
    $imageOffset += $pngBytes.Length
}

# Write image data
foreach ($size in $iconSizes) {
    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($png, 0, 0, $size, $size)
    $g.Dispose()

    $pngMs = New-Object System.IO.MemoryStream
    $bmp.Save($pngMs, [System.Drawing.Imaging.ImageFormat]::Png)
    $pngBytes = $pngMs.ToArray()
    $pngMs.Dispose()
    $bmp.Dispose()

    $bw.Write($pngBytes)
}

$bw.Flush()
[System.IO.File]::WriteAllBytes($iconDir, $ms.ToArray())
$ms.Dispose()
$bw.Dispose()
$png.Dispose()

Write-Host "icon.ico created with sizes: $($iconSizes -join ', ')"