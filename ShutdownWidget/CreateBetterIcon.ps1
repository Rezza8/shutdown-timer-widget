Add-Type -AssemblyName System.Drawing

$bmp = New-Object System.Drawing.Bitmap 256, 256
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

# ============================================================
# MODERN CLEAR ICON: White circle background, blue timer
# ============================================================

# Outer circle - clean white with subtle border
$outerRect = New-Object System.Drawing.Rectangle 8, 8, 240, 240
$outerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $outerRect, '#FFFFFF', '#F0F0F0', 90
$g.FillEllipse($outerBrush, $outerRect)

# Subtle border
$borderPen = New-Object System.Drawing.Pen('#DDDDDD', 2)
$g.DrawEllipse($borderPen, 8, 8, 240, 240)

# Inner circle - Windows blue
$innerRect = New-Object System.Drawing.Rectangle 32, 32, 192, 192
$innerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $innerRect, '#0078D7', '#005A9E', 45
$g.FillEllipse($innerBrush, $innerRect)

# ============================================================
# TIMER DESIGN: Simple, clear, recognizable
# ============================================================

# Clock face - white circle in center
$faceRect = New-Object System.Drawing.Rectangle 64, 64, 128, 128
$g.FillEllipse([System.Drawing.Brushes]::White, $faceRect)

# 4 main hour markers (12, 3, 6, 9) - thick and clear
$markPen = New-Object System.Drawing.Pen('#333333', 4)
$markPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$markPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

# 12 o'clock
$g.DrawLine($markPen, 128, 76, 128, 86)
# 3 o'clock
$g.DrawLine($markPen, 170, 128, 180, 128)
# 6 o'clock
$g.DrawLine($markPen, 128, 170, 128, 180)
# 9 o'clock
$g.DrawLine($markPen, 76, 128, 86, 128)

# 4 minor markers (1:30, 4:30, 7:30, 10:30) - thinner
$minorPen = New-Object System.Drawing.Pen('#666666', 2)
$minorPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$minorPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

$angles = @(45, 135, 225, 315)
foreach ($deg in $angles) {
    $rad = $deg * [Math]::PI / 180
    $x1 = 128 + [Math]::Cos($rad) * 50
    $y1 = 128 + [Math]::Sin($rad) * 50
    $x2 = 128 + [Math]::Cos($rad) * 60
    $y2 = 128 + [Math]::Sin($rad) * 60
    $g.DrawLine($minorPen, $x1, $y1, $x2, $y2)
}

# ============================================================
# CLOCK HANDS - Clear and distinct
# ============================================================

# Hour hand - short, thick, blue
$hourPen = New-Object System.Drawing.Pen('#0078D7', 6)
$hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$angleH = -30 * [Math]::PI / 180  # Pointing at ~11 (countdown)
$xH = 128 + [Math]::Cos($angleH) * 35
$yH = 128 + [Math]::Sin($angleH) * 35
$g.DrawLine($hourPen, 128, 128, $xH, $yH)

# Minute hand - long, thinner, dark blue
$minPen = New-Object System.Drawing.Pen('#004B87', 4)
$minPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$angleM = -90 * [Math]::PI / 180  # Pointing at 12
$xM = 128 + [Math]::Cos($angleM) * 55
$yM = 128 + [Math]::Sin($angleM) * 55
$g.DrawLine($minPen, 128, 128, $xM, $yM)

# ============================================================
# POWER SYMBOL in center - Clear shutdown indicator
# ============================================================

$powerPen = New-Object System.Drawing.Pen('#FFFFFF', 5)
$powerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$powerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

# Power circle (broken at top)
$g.DrawArc($powerPen, 108, 108, 40, 40, -30, 300)

# Power line (vertical through center)
$g.DrawLine($powerPen, 128, 100, 128, 130)

# ============================================================
# CENTER DOT
# ============================================================
$g.FillEllipse([System.Drawing.Brushes]::White, 124, 124, 8, 8)
$g.FillEllipse([System.Drawing.Brushes]::Blue, 126, 126, 4, 4)

# ============================================================
# SUBTLE GLOSS EFFECT (top highlight)
# ============================================================
$glossRect = New-Object System.Drawing.Rectangle 40, 40, 176, 60
$glossBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $glossRect, 
    [System.Drawing.Color]::FromArgb(60, 255, 255, 255), 
    [System.Drawing.Color]::FromArgb(0, 255, 255, 255), 90
$g.FillEllipse($glossBrush, $glossRect)

$g.Dispose()
$bmp.Save('D:\OPENAI\shutdown timer widget\ShutdownWidget\icon.png', [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

Write-Host "Better icon.png created"