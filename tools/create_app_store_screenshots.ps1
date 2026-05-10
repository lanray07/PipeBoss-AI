$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$dir = Join-Path (Get-Location) 'AppStoreAssets\Screenshots'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

function New-Brush($hex) {
    New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-PenC($hex, $width = 1) {
    New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
}

function Draw-RoundRect($g, $x, $y, $ww, $hh, $r, $fill, $stroke = $null) {
    if ($r -le 0) {
        $rect = New-Object System.Drawing.RectangleF($x, $y, $ww, $hh)
        if ($fill) { $g.FillRectangle((New-Brush $fill), $rect) }
        if ($stroke) { $g.DrawRectangle((New-PenC $stroke 2), $x, $y, $ww, $hh) }
        return
    }

    $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $gp.AddArc($x, $y, $d, $d, 180, 90)
    $gp.AddArc($x + $ww - $d, $y, $d, $d, 270, 90)
    $gp.AddArc($x + $ww - $d, $y + $hh - $d, $d, $d, 0, 90)
    $gp.AddArc($x, $y + $hh - $d, $d, $d, 90, 90)
    $gp.CloseFigure()
    if ($fill) { $g.FillPath((New-Brush $fill), $gp) }
    if ($stroke) { $g.DrawPath((New-PenC $stroke 2), $gp) }
}

function Draw-Text($g, $s, $x, $y, $size, $color = '#102033', $style = 'Regular', $maxWidth = 0, $maxHeight = 500) {
    $fontStyle = [System.Drawing.FontStyle]::Regular
    if ($style -eq 'Bold' -or $style -eq 'Semibold') { $fontStyle = [System.Drawing.FontStyle]::Bold }
    $font = New-Object System.Drawing.Font('Segoe UI', $size, $fontStyle, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Brush $color
    if ($maxWidth -gt 0) {
        $g.DrawString($s, $font, $brush, (New-Object System.Drawing.RectangleF($x, $y, $maxWidth, $maxHeight)))
    } else {
        $g.DrawString($s, $font, $brush, $x, $y)
    }
}

function Draw-IconCircle($g, $x, $y, $label, $fill, $size = 72) {
    $g.FillEllipse((New-Brush $fill), $x, $y, $size, $size)
    Draw-Text $g $label ($x + ($size * 0.28)) ($y + ($size * 0.20)) ([int]($size * 0.38)) '#FFFFFF' 'Bold'
}

function Draw-Gauge($g, $cx, $cy, $radius, $value) {
    $penBg = New-PenC '#D7E4F0' 18
    $penFg = New-PenC '#0B74D1' 18
    $rect = [System.Drawing.RectangleF]::new([float]($cx - $radius), [float]($cy - $radius), [float]($radius * 2), [float]($radius * 2))
    $g.DrawArc($penBg, $rect, 170, 200)
    $g.DrawArc($penFg, $rect, 170, [int](200 * $value))
    $needleAngle = (170 + (200 * $value)) * [Math]::PI / 180
    $nx = $cx + [Math]::Cos($needleAngle) * ($radius - 18)
    $ny = $cy + [Math]::Sin($needleAngle) * ($radius - 18)
    $needle = New-PenC '#F97316' 8
    $needle.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $needle.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($needle, $cx, $cy, [float]$nx, [float]$ny)
    $g.FillEllipse((New-Brush '#102033'), $cx - 10, $cy - 10, 20, 20)
}

function Draw-PhoneScreenshot($path) {
    $w = 1242
    $h = 2688
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#F5F8FB'))

    Draw-RoundRect $g 0 0 $w 260 0 '#071B33'
    Draw-Text $g '9:41' 66 58 34 '#FFFFFF' 'Bold'
    Draw-Text $g 'PipeBoss AI' 66 124 48 '#FFFFFF' 'Bold'
    Draw-Text $g 'Plumbing career simulator' 66 184 28 '#B9D7F7'
    Draw-RoundRect $g 964 70 210 72 36 '#F97316' '#F97316'
    Draw-Text $g 'Level 8' 1028 88 30 '#FFFFFF' 'Bold'

    Draw-Text $g 'Today Dashboard' 66 330 52 '#102033' 'Bold'
    Draw-Text $g 'Train with realistic jobs, quizzes, tools, and business upgrades.' 66 396 30 '#53606D' 'Regular' 1100 120

    Draw-RoundRect $g 66 555 1110 315 32 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle $g 108 610 'XP' '#0B74D1' 84
    Draw-Text $g 'Qualified Plumber' 220 604 40 '#102033' 'Bold'
    Draw-Text $g '8,420 XP' 220 660 30 '#53606D'
    Draw-RoundRect $g 220 740 790 34 17 '#E5EDF5'
    Draw-RoundRect $g 220 740 560 34 17 '#0B74D1'
    Draw-Text $g 'Master path' 1028 724 28 '#0B74D1' 'Bold'

    Draw-RoundRect $g 66 930 530 230 28 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle $g 106 978 '$' '#F97316' 78
    Draw-Text $g 'Coins' 208 974 28 '#53606D'
    Draw-Text $g '1,840' 208 1012 52 '#102033' 'Bold'
    Draw-Text $g 'Earned from correct repairs' 106 1090 24 '#53606D'
    Draw-RoundRect $g 646 930 530 230 28 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle $g 686 978 '4.6' '#FFC857' 78
    Draw-Text $g 'Reputation' 788 974 28 '#53606D'
    Draw-Text $g 'Excellent' 788 1012 44 '#102033' 'Bold'
    Draw-Text $g 'Customer ratings unlock jobs' 686 1090 24 '#53606D'

    Draw-Text $g 'Job Board' 66 1250 46 '#102033' 'Bold'
    $jobs = @(
        @{T='Leaking pipe under sink'; D='Beginner - 12 min - Compression fitting'; C='#0B74D1'; S='Ready'},
        @{T='Blocked drain'; D='Beginner - 15 min - Plunger and auger'; C='#178A42'; S='Ready'},
        @{T='Burst pipe emergency'; D='Emergency pack - isolate supply fast'; C='#DC2626'; S='Pack'},
        @{T='Commercial maintenance'; D='City expansion - pressure and drainage'; C='#F97316'; S='Pack'}
    )
    $y = 1320
    foreach ($job in $jobs) {
        Draw-RoundRect $g 66 $y 1110 190 28 '#FFFFFF' '#DDE6EF'
        Draw-IconCircle $g 104 ($y + 46) 'P' $job.C 70
        Draw-Text $g $job.T 205 ($y + 38) 34 '#102033' 'Bold'
        Draw-Text $g $job.D 205 ($y + 90) 25 '#53606D' 'Regular' 660 70
        Draw-RoundRect $g 940 ($y + 62) 160 58 29 '#EAF6FF' '#A5D8FF'
        Draw-Text $g $job.S 992 ($y + 73) 24 '#0B74D1' 'Bold'
        $y += 218
    }

    Draw-RoundRect $g 66 2240 1110 280 32 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Interactive Repair' 108 2285 38 '#102033' 'Bold'
    Draw-Text $g 'Low pressure reported upstairs. Inspect symptoms, choose tools, diagnose the cause, then select the repair.' 108 2342 26 '#53606D' 'Regular' 760 120
    Draw-Gauge $g 990 2375 108 0.68
    Draw-RoundRect $g 108 2448 305 58 29 '#0B74D1' '#0B74D1'
    Draw-Text $g 'Start Job' 206 2459 25 '#FFFFFF' 'Bold'

    Draw-Text $g 'Educational training simulation only. Follow local regulations for real plumbing work.' 66 2615 22 '#71808F' 'Regular' 1050 50

    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

function Draw-iPadScreenshot($path) {
    $w = 2048
    $h = 2732
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#F5F8FB'))

    Draw-RoundRect $g 0 0 $w 230 0 '#071B33'
    Draw-Text $g 'PipeBoss AI' 82 72 60 '#FFFFFF' 'Bold'
    Draw-Text $g 'Train practical plumbing decisions through realistic jobs' 82 142 30 '#B9D7F7'
    Draw-RoundRect $g 1670 76 270 72 36 '#F97316' '#F97316'
    Draw-Text $g 'PRO READY' 1722 91 30 '#FFFFFF' 'Bold'

    Draw-Text $g 'Run the day like a plumber' 82 310 62 '#102033' 'Bold'
    Draw-Text $g 'Inspect faults, choose tools, diagnose causes, make repair decisions, and grow a virtual plumbing business.' 82 388 32 '#53606D' 'Regular' 1640 110

    Draw-RoundRect $g 82 555 580 300 32 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Career Level' 130 602 28 '#53606D'
    Draw-Text $g 'Qualified Plumber' 130 650 44 '#102033' 'Bold'
    Draw-RoundRect $g 130 756 420 34 17 '#E5EDF5'
    Draw-RoundRect $g 130 756 285 34 17 '#0B74D1'

    Draw-RoundRect $g 734 555 580 300 32 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Performance' 782 602 28 '#53606D'
    Draw-Text $g '92% Accuracy' 782 650 44 '#102033' 'Bold'
    Draw-Text $g 'Customer rating 4.6' 782 724 28 '#53606D'

    Draw-RoundRect $g 1386 555 580 300 32 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Tool Inventory' 1434 602 28 '#53606D'
    Draw-Text $g '18 Tools' 1434 650 44 '#102033' 'Bold'
    Draw-Text $g 'Advanced pack available' 1434 724 28 '#53606D'

    Draw-Text $g 'Live Job Simulation' 82 975 50 '#102033' 'Bold'
    Draw-RoundRect $g 82 1048 1200 730 34 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Customer Brief' 132 1098 34 '#102033' 'Bold'
    Draw-Text $g 'Bathroom radiator is not heating. Customer reports gurgling and cold spots after recent pipe work.' 132 1150 28 '#53606D' 'Regular' 1020 100
    Draw-Text $g 'Symptoms' 132 1280 30 '#102033' 'Bold'
    $symptoms = @('Cold top section', 'Pressure gauge low', 'Air noise in pipework', 'No visible leak')
    $sy = 1334
    foreach ($sym in $symptoms) {
        Draw-RoundRect $g 132 $sy 475 66 18 '#EAF6FF' '#A5D8FF'
        Draw-Text $g $sym 166 ($sy + 14) 24 '#0B74D1' 'Bold'
        $sy += 86
    }
    Draw-Text $g 'Diagnosis Challenge' 690 1280 30 '#102033' 'Bold'
    Draw-RoundRect $g 690 1334 510 86 22 '#0B74D1' '#0B74D1'
    Draw-Text $g 'Air trapped in radiator' 738 1354 27 '#FFFFFF' 'Bold'
    Draw-RoundRect $g 690 1440 510 86 22 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Faulty mixer valve' 738 1460 27 '#53606D' 'Bold'
    Draw-RoundRect $g 690 1546 510 86 22 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Undersized waste pipe' 738 1566 27 '#53606D' 'Bold'

    Draw-RoundRect $g 1360 1048 606 730 34 '#FFFFFF' '#DDE6EF'
    Draw-Text $g 'Pressure Meter' 1410 1098 34 '#102033' 'Bold'
    Draw-Gauge $g 1662 1330 205 0.42
    Draw-Text $g '0.8 bar' 1550 1530 52 '#102033' 'Bold'
    Draw-Text $g 'Safe training tip: isolate and follow local regulations before real-world repair work.' 1410 1620 27 '#53606D' 'Regular' 480 120

    Draw-Text $g 'Business and Learning' 82 1900 50 '#102033' 'Bold'
    Draw-RoundRect $g 82 1974 580 420 32 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle $g 130 2030 'B' '#F97316' 88
    Draw-Text $g 'Upgrade Business' 250 2028 38 '#102033' 'Bold'
    Draw-Text $g 'Add vans, tools, apprentices, and contract capability.' 250 2084 28 '#53606D' 'Regular' 330 100

    Draw-RoundRect $g 734 1974 580 420 32 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle $g 782 2030 'Q' '#0B74D1' 88
    Draw-Text $g 'Quiz Repairs' 902 2028 38 '#102033' 'Bold'
    Draw-Text $g 'Practical diagnosis questions after key jobs.' 902 2084 28 '#53606D' 'Regular' 330 100

    Draw-RoundRect $g 1386 1974 580 420 32 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle $g 1434 2030 'C' '#178A42' 88
    Draw-Text $g 'Knowledge Cards' 1554 2028 38 '#102033' 'Bold'
    Draw-Text $g 'Safety, pipe materials, fittings, pressure, drainage, and customer communication.' 1554 2084 28 '#53606D' 'Regular' 330 130

    Draw-RoundRect $g 82 2508 1884 120 28 '#EAF6FF' '#A5D8FF'
    Draw-Text $g 'PipeBoss AI is an educational simulation, not real-world repair advice.' 130 2540 32 '#0B74D1' 'Bold'
    Draw-Text $g 'Always follow local regulations and consult a qualified professional.' 130 2584 26 '#53606D'

    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$phone = Join-Path $dir 'pipeboss-iphone65-dashboard.png'
$ipad = Join-Path $dir 'pipeboss-ipad129-dashboard.png'
Draw-PhoneScreenshot $phone
Draw-iPadScreenshot $ipad

Get-Item $phone, $ipad | Select-Object FullName, Length
