$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$dir = Join-Path (Get-Location) 'AppStoreAssets\IAPReview'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$path = Join-Path $dir 'pipeboss-pro-subscription.png'

$w = 1290
$h = 2796
$bmp = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

function New-Brush($hex) {
    New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-PenC($hex, $width = 1) {
    New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
}

function Draw-RoundRect($x, $y, $ww, $hh, $r, $fill, $stroke = $null) {
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

function Draw-Text($s, $x, $y, $size, $color = '#102033', $style = 'Regular', $maxWidth = 0, $maxHeight = 500) {
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

function Draw-Check($x, $y) {
    $g.FillEllipse((New-Brush '#178A42'), $x, $y, 42, 42)
    $pen = New-PenC '#FFFFFF' 6
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($pen, $x + 11, $y + 22, $x + 18, $y + 30)
    $g.DrawLine($pen, $x + 18, $y + 30, $x + 31, $y + 13)
}

$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#F5F8FB'))

Draw-RoundRect 0 0 $w 250 0 '#071B33'
Draw-Text '9:41' 68 58 34 '#FFFFFF' 'Bold'
Draw-Text 'PipeBoss AI' 68 122 44 '#FFFFFF' 'Bold'
Draw-Text 'PipeBoss Pro' 68 178 28 '#B9D7F7' 'Bold'
Draw-RoundRect 1010 72 208 72 36 '#F97316' '#F97316'
Draw-Text 'PRO' 1082 88 34 '#FFFFFF' 'Bold'

Draw-Text 'Unlock the full training yard' 68 326 58 '#102033' 'Bold'
Draw-Text 'Unlimited jobs, advanced scenarios, boiler and heating modules, commercial contracts, exam-style quizzes, mentor hints, performance analytics, and no ads.' 68 410 31 '#53606D' 'Regular' 1130 220

Draw-RoundRect 68 610 1154 268 32 '#FFFFFF' '#DDE6EF'
Draw-Text 'Career Progress' 118 652 28 '#5D6A77'
Draw-Text 'Apprentice to Master Plumber' 118 692 42 '#102033' 'Bold'
Draw-RoundRect 118 778 920 32 16 '#E5EDF5'
Draw-RoundRect 118 778 650 32 16 '#0B74D1'
Draw-Text 'Level 8' 1070 758 32 '#0B74D1' 'Bold'

Draw-Text 'Included with PipeBoss Pro' 68 960 40 '#102033' 'Bold'
$benefits = @(
    'Unlimited plumbing jobs and daily energy',
    'Advanced repair, commercial, boiler, and heating modules',
    'AI-style mentor hints and exam-style quizzes',
    'Detailed performance analytics and no ads',
    'Cloud progress sync placeholder for future release'
)
$y = 1032
foreach ($benefit in $benefits) {
    Draw-Check 84 $y
    Draw-Text $benefit 150 ($y - 2) 30 '#102033' 'Regular' 980 80
    $y += 76
}

Draw-Text 'Choose a plan' 68 1488 40 '#102033' 'Bold'
Draw-RoundRect 68 1560 552 390 34 '#FFFFFF' '#DDE6EF'
Draw-Text 'Monthly' 118 1618 36 '#102033' 'Bold'
Draw-Text 'PipeBoss Pro Monthly' 118 1672 28 '#53606D'
Draw-Text '$4.99' 118 1750 64 '#102033' 'Bold'
Draw-Text 'per month' 300 1784 28 '#53606D'
Draw-RoundRect 118 1854 420 70 35 '#0B74D1' '#0B74D1'
Draw-Text 'Subscribe Monthly' 218 1870 28 '#FFFFFF' 'Bold'

Draw-RoundRect 670 1560 552 390 34 '#FFFFFF' '#F97316'
Draw-RoundRect 1010 1592 150 50 25 '#FFF3E8' '#FDBA74'
Draw-Text 'Best value' 1034 1604 22 '#C2410C' 'Bold'
Draw-Text 'Yearly' 720 1618 36 '#102033' 'Bold'
Draw-Text 'PipeBoss Pro Yearly' 720 1672 28 '#53606D'
Draw-Text '$39.99' 720 1750 64 '#102033' 'Bold'
Draw-Text 'per year' 940 1784 28 '#53606D'
Draw-RoundRect 720 1854 420 70 35 '#F97316' '#F97316'
Draw-Text 'Subscribe Yearly' 824 1870 28 '#FFFFFF' 'Bold'

Draw-RoundRect 68 2056 1154 280 30 '#EAF6FF' '#A5D8FF'
Draw-Text 'Subscription terms' 112 2092 32 '#102033' 'Bold'
Draw-Text 'Payment is charged to your Apple ID at confirmation. Subscription renews automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel in App Store account settings.' 112 2146 26 '#53606D' 'Regular' 1030 140
Draw-Text 'Restore Purchases' 112 2268 27 '#0B74D1' 'Bold'
Draw-Text 'Manage Subscription' 392 2268 27 '#0B74D1' 'Bold'

Draw-RoundRect 68 2420 1154 150 28 '#FFFFFF' '#DDE6EF'
Draw-Text 'Privacy Policy' 112 2460 28 '#0B74D1' 'Bold'
Draw-Text 'Terms of Use' 390 2460 28 '#0B74D1' 'Bold'
Draw-Text 'PipeBoss AI does not require an account and is designed to avoid unnecessary personal data collection.' 112 2510 24 '#53606D' 'Regular' 980 70

Draw-Text 'PipeBoss AI is for educational training and simulation only. Always follow local regulations and consult a qualified professional for real-world plumbing work.' 68 2650 23 '#71808F' 'Regular' 1130 100

$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Get-Item $path | Select-Object FullName, Length
