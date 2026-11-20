Add-Type -AssemblyName System.Drawing

# Load the provided chronometer.png
$png = [System.Drawing.Image]::FromFile('D:\OPENAI\shutdown timer widget\ShutdownWidget\chronometer.png')

# Create ICO with multiple sizes
$iconSizes = @(16, 24, 32, 48, 64, 128, 256)
$iconDir = "D:\OPENAI\shutdown timer widget\ShutdownWidget\icon.ico"

$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms

# ICO header
$bw.Write([short]0)
$bw.Write([short]1)
$bw.Write([short]$iconSizes.Count)

$imageOffset = 6 + $iconSizes.Count * 16

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

    $w = if ($size -eq 256) { 0 } else { $size }
    $h = if ($size -eq 256) { 0 } else { $size }
    $bw.Write([byte]$w)
    $bw.Write([byte]$h)
    $bw.Write([byte]0)
    $bw.Write([byte]0)
    $bw.Write([short]0)
    $bw.Write([short]32)
    $bw.Write([int]$pngBytes.Length)
    $bw.Write([int]$imageOffset)
    $imageOffset += $pngBytes.Length
}

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

Write-Host "icon.ico created from chronometer.png with sizes: $($iconSizes -join ', ')"