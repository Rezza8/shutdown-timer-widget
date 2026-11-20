Add-Type -AssemblyName System.Drawing

$png = [System.Drawing.Image]::FromFile('switch.png')
$sizes = @(16, 32, 48, 64, 128, 256)
$iconDir = New-Object System.Collections.Generic.List[System.Drawing.Icon]

foreach ($s in $sizes) {
    $bmp = New-Object System.Drawing.Bitmap($png, $s, $s)
    $iconDir.Add([System.Drawing.Icon]::FromHandle($bmp.GetHicon()))
}

$fs = [System.IO.File]::Create('icon.ico')
$iconDir[0].Save($fs)
$fs.Close()

Write-Host "Created icon.ico with sizes: $sizes"