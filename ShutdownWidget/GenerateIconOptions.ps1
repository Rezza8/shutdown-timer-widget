Add-Type -AssemblyName System.Drawing

function CreateIcon($name, $scriptBlock) {
    $bmp = New-Object System.Drawing.Bitmap 256, 256
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    & $scriptBlock $g $bmp
    $bmp.Save("D:\OPENAI\shutdown timer widget\ShutdownWidget\icon_$name.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Created icon_$name.png"
}

# ============================================================
# OPTION 1: Clean Modern (current)
# ============================================================
CreateIcon "1_clean_modern" {
    param($g, $bmp)
    # White outer, blue inner
    $outerRect = New-Object System.Drawing.Rectangle 8, 8, 240, 240
    $outerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $outerRect, '#FFFFFF', '#F0F0F0', 90
    $g.FillEllipse($outerBrush, $outerRect)
    $borderPen = New-Object System.Drawing.Pen('#DDDDDD', 2)
    $g.DrawEllipse($borderPen, 8, 8, 240, 240)
    
    $innerRect = New-Object System.Drawing.Rectangle 32, 32, 192, 192
    $innerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $innerRect, '#0078D7', '#005A9E', 45
    $g.FillEllipse($innerBrush, $innerRect)
    
    $faceRect = New-Object System.Drawing.Rectangle 64, 64, 128, 128
    $g.FillEllipse([System.Drawing.Brushes]::White, $faceRect)
    
    # 4 main markers
    $markPen = New-Object System.Drawing.Pen('#333333', 4)
    $markPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $markPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($markPen, 128, 76, 128, 86)
    $g.DrawLine($markPen, 170, 128, 180, 128)
    $g.DrawLine($markPen, 128, 170, 128, 180)
    $g.DrawLine($markPen, 76, 128, 86, 128)
    
    # Hands
    $hourPen = New-Object System.Drawing.Pen('#0078D7', 6)
    $hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleH = -30 * [Math]::PI / 180
    $xH = 128 + [Math]::Cos($angleH) * 35
    $yH = 128 + [Math]::Sin($angleH) * 35
    $g.DrawLine($hourPen, 128, 128, $xH, $yH)
    
    $minPen = New-Object System.Drawing.Pen('#004B87', 4)
    $minPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleM = -90 * [Math]::PI / 180
    $xM = 128 + [Math]::Cos($angleM) * 55
    $yM = 128 + [Math]::Sin($angleM) * 55
    $g.DrawLine($minPen, 128, 128, $xM, $yM)
    
    # Power symbol - white
    $powerPen = New-Object System.Drawing.Pen('#FFFFFF', 5)
    $powerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $powerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($powerPen, 108, 108, 40, 40, -30, 300)
    $g.DrawLine($powerPen, 128, 100, 128, 130)
    
    $g.FillEllipse([System.Drawing.Brushes]::White, 124, 124, 8, 8)
    $g.FillEllipse([System.Drawing.Brushes]::Blue, 126, 126, 4, 4)
}

# ============================================================
# OPTION 2: Dark Mode / Windows 11 Style
# ============================================================
CreateIcon "2_dark_mode" {
    param($g, $bmp)
    # Dark background circle
    $outerRect = New-Object System.Drawing.Rectangle 12, 12, 232, 232
    $outerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $outerRect, '#1F1F1F', '#2D2D2D', 90
    $g.FillEllipse($outerBrush, $outerRect)
    $borderPen = New-Object System.Drawing.Pen('#3E3E42', 3)
    $g.DrawEllipse($borderPen, 12, 12, 232, 232)
    
    # Blue accent ring
    $ringRect = New-Object System.Drawing.Rectangle 36, 36, 184, 184
    $ringBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $ringRect, '#0078D7', '#005A9E', 45
    $g.FillEllipse($ringBrush, $ringRect)
    
    # Inner dark face
    $faceRect = New-Object System.Drawing.Rectangle 56, 56, 144, 144
    $faceBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $faceRect, '#1F1F1F', '#2D2D2D', 90
    $g.FillEllipse($faceBrush, $faceRect)
    
    # White markers
    $markPen = New-Object System.Drawing.Pen('#FFFFFF', 4)
    $markPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $markPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($markPen, 128, 68, 128, 80)
    $g.DrawLine($markPen, 176, 128, 188, 128)
    $g.DrawLine($markPen, 128, 176, 128, 188)
    $g.DrawLine($markPen, 68, 128, 80, 128)
    
    # White hands
    $hourPen = New-Object System.Drawing.Pen('#FFFFFF', 6)
    $hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleH = -30 * [Math]::PI / 180
    $xH = 128 + [Math]::Cos($angleH) * 40
    $yH = 128 + [Math]::Sin($angleH) * 40
    $g.DrawLine($hourPen, 128, 128, $xH, $yH)
    
    $minPen = New-Object System.Drawing.Pen('#CCCCCC', 4)
    $minPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleM = -90 * [Math]::PI / 180
    $xM = 128 + [Math]::Cos($angleM) * 60
    $yM = 128 + [Math]::Sin($angleM) * 60
    $g.DrawLine($minPen, 128, 128, $xM, $yM)
    
    # Power symbol - bright blue
    $powerPen = New-Object System.Drawing.Pen('#0078D7', 5)
    $powerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $powerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($powerPen, 108, 108, 40, 40, -30, 300)
    $g.DrawLine($powerPen, 128, 100, 128, 130)
    
    $g.FillEllipse([System.Drawing.Brushes]::White, 124, 124, 8, 8)
    $g.FillEllipse([System.Drawing.Brushes]::Blue, 126, 126, 4, 4)
}

# ============================================================
# OPTION 3: Flat Minimal (Windows 11 Fluent)
# ============================================================
CreateIcon "3_flat_minimal" {
    param($g, $bmp)
    # Single color background
    $outerRect = New-Object System.Drawing.Rectangle 0, 0, 256, 256
    $g.FillEllipse([System.Drawing.Brushes]::White, $outerRect)
    
    # Blue circle - flat
    $innerRect = New-Object System.Drawing.Rectangle 40, 40, 176, 176
    $g.FillEllipse([System.Drawing.Brushes]::FromArgb(255, 0, 120, 215), $innerRect)
    
    # Simple clock hands only (no face)
    $hourPen = New-Object System.Drawing.Pen('#FFFFFF', 8)
    $hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $angleH = -30 * [Math]::PI / 180
    $xH = 128 + [Math]::Cos($angleH) * 45
    $yH = 128 + [Math]::Sin($angleH) * 45
    $g.DrawLine($hourPen, 128, 128, $xH, $yH)
    
    $minPen = New-Object System.Drawing.Pen('#FFFFFF', 5)
    $minPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $angleM = -90 * [Math]::PI / 180
    $xM = 128 + [Math]::Cos($angleM) * 65
    $yM = 128 + [Math]::Sin($angleM) * 65
    $g.DrawLine($minPen, 128, 128, $xM, $yM)
    
    # Center dot
    $g.FillEllipse([System.Drawing.Brushes]::White, 120, 120, 16, 16)
    
    # Power symbol cutout (transparent)
    $powerBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Transparent)
    $g.FillEllipse($powerBrush, 108, 108, 40, 40)  # This won't work for transparency easily
    
    # Instead draw white power symbol on top
    $powerPen = New-Object System.Drawing.Pen('#FFFFFF', 6)
    $powerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $powerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($powerPen, 108, 108, 40, 40, -30, 300)
    $g.DrawLine($powerPen, 128, 100, 128, 130)
}

# ============================================================
# OPTION 4: Red Alert / Warning Style (shutdown = danger)
# ============================================================
CreateIcon "4_red_alert" {
    param($g, $bmp)
    # White outer
    $outerRect = New-Object System.Drawing.Rectangle 8, 8, 240, 240
    $outerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $outerRect, '#FFFFFF', '#F5F5F5', 90
    $g.FillEllipse($outerBrush, $outerRect)
    $borderPen = New-Object System.Drawing.Pen('#E0E0E0', 2)
    $g.DrawEllipse($borderPen, 8, 8, 240, 240)
    
    # Red inner (shutdown = stop/danger)
    $innerRect = New-Object System.Drawing.Rectangle 32, 32, 192, 192
    $innerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $innerRect, '#E81123', '#A40E1C', 45
    $g.FillEllipse($innerBrush, $innerRect)
    
    $faceRect = New-Object System.Drawing.Rectangle 64, 64, 128, 128
    $g.FillEllipse([System.Drawing.Brushes]::White, $faceRect)
    
    # Black markers
    $markPen = New-Object System.Drawing.Pen('#1A1A1A', 4)
    $markPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $markPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($markPen, 128, 76, 128, 86)
    $g.DrawLine($markPen, 170, 128, 180, 128)
    $g.DrawLine($markPen, 128, 170, 128, 180)
    $g.DrawLine($markPen, 76, 128, 86, 128)
    
    # White hands on red
    $hourPen = New-Object System.Drawing.Pen('#FFFFFF', 6)
    $hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleH = -30 * [Math]::PI / 180
    $xH = 128 + [Math]::Cos($angleH) * 35
    $yH = 128 + [Math]::Sin($angleH) * 35
    $g.DrawLine($hourPen, 128, 128, $xH, $yH)
    
    $minPen = New-Object System.Drawing.Pen('#FFFFFF', 4)
    $minPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleM = -90 * [Math]::PI / 180
    $xM = 128 + [Math]::Cos($angleM) * 55
    $yM = 128 + [Math]::Sin($angleM) * 55
    $g.DrawLine($minPen, 128, 128, $xM, $yM)
    
    # White power symbol
    $powerPen = New-Object System.Drawing.Pen('#FFFFFF', 5)
    $powerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $powerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($powerPen, 108, 108, 40, 40, -30, 300)
    $g.DrawLine($powerPen, 128, 100, 128, 130)
    
    $g.FillEllipse([System.Drawing.Brushes]::White, 124, 124, 8, 8)
    $g.FillEllipse([System.Drawing.Brushes]::Red, 126, 126, 4, 4)
}

# ============================================================
# OPTION 5: Orange/Amber Timer (countdown warning)
# ============================================================
CreateIcon "5_amber_timer" {
    param($g, $bmp)
    # White outer
    $outerRect = New-Object System.Drawing.Rectangle 8, 8, 240, 240
    $outerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $outerRect, '#FFFFFF', '#F0F0F0', 90
    $g.FillEllipse($outerBrush, $outerRect)
    $borderPen = New-Object System.Drawing.Pen('#DDDDDD', 2)
    $g.DrawEllipse($borderPen, 8, 8, 240, 240)
    
    # Amber/orange inner (timer/warning color)
    $innerRect = New-Object System.Drawing.Rectangle 32, 32, 192, 192
    $innerBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $innerRect, '#FF8C00', '#E67300', 45
    $g.FillEllipse($innerBrush, $innerRect)
    
    $faceRect = New-Object System.Drawing.Rectangle 64, 64, 128, 128
    $g.FillEllipse([System.Drawing.Brushes]::White, $faceRect)
    
    # Dark markers
    $markPen = New-Object System.Drawing.Pen('#333333', 4)
    $markPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $markPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($markPen, 128, 76, 128, 86)
    $g.DrawLine($markPen, 170, 128, 180, 128)
    $g.DrawLine($markPen, 128, 170, 128, 180)
    $g.DrawLine($markPen, 76, 128, 86, 128)
    
    # White hands
    $hourPen = New-Object System.Drawing.Pen('#FFFFFF', 6)
    $hourPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $hourPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleH = -30 * [Math]::PI / 180
    $xH = 128 + [Math]::Cos($angleH) * 35
    $yH = 128 + [Math]::Sin($angleH) * 35
    $g.DrawLine($hourPen, 128, 128, $xH, $yH)
    
    $minPen = New-Object System.Drawing.Pen('#FFFFFF', 4)
    $minPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $minPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
    $angleM = -90 * [Math]::PI / 180
    $xM = 128 + [Math]::Cos($angleM) * 55
    $yM = 128 + [Math]::Sin($angleM) * 55
    $g.DrawLine($minPen, 128, 128, $xM, $yM)
    
    # White power symbol
    $powerPen = New-Object System.Drawing.Pen('#FFFFFF', 5)
    $powerPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $powerPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawArc($powerPen, 108, 108, 40, 40, -30, 300)
    $g.DrawLine($powerPen, 128, 100, 128, 130)
    
    $g.FillEllipse([System.Drawing.Brushes]::White, 124, 124, 8, 8)
    $g.FillEllipse([System.Drawing.Brushes]::Orange, 126, 126, 4, 4)
}

Write-Host "All 5 icon options created!"