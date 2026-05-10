$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$dir = Join-Path (Get-Location) 'AppStoreAssets\IAPReview'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
$path = Join-Path $dir 'pipeboss-iap-packs.png'

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

function Draw-Text($s, $x, $y, $size, $color = '#102033', $style = 'Regular', $maxWidth = 0) {
    $fontStyle = [System.Drawing.FontStyle]::Regular
    if ($style -eq 'Bold' -or $style -eq 'Semibold') { $fontStyle = [System.Drawing.FontStyle]::Bold }
    $font = New-Object System.Drawing.Font('Segoe UI', $size, $fontStyle, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Brush $color
    if ($maxWidth -gt 0) {
        $g.DrawString($s, $font, $brush, (New-Object System.Drawing.RectangleF($x, $y, $maxWidth, 500)))
    } else {
        $g.DrawString($s, $font, $brush, $x, $y)
    }
}

function Draw-IconCircle($x, $y, $label, $fill = '#0B74D1') {
    $g.FillEllipse((New-Brush $fill), $x, $y, 86, 86)
    Draw-Text $label ($x + 23) ($y + 17) 36 '#FFFFFF' 'Bold'
}

$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#F5F8FB'))

Draw-RoundRect 0 0 $w 190 0 '#071B33'
Draw-Text '9:41' 68 58 34 '#FFFFFF' 'Bold'
Draw-Text 'PipeBoss AI' 68 118 42 '#FFFFFF' 'Bold'
Draw-Text 'Business & Packs' 68 167 24 '#B9D7F7'
Draw-RoundRect 1035 64 180 60 30 '#123D66' '#255E95'
Draw-Text 'Level 8' 1075 78 26 '#FFFFFF' 'Bold'

Draw-RoundRect 54 230 1182 190 28 '#FFFFFF' '#DDE6EF'
Draw-IconCircle 88 282 '$' '#F97316'
Draw-Text 'Coins' 196 268 24 '#5D6A77'
Draw-Text '1,840' 196 302 44 '#102033' 'Bold'
Draw-IconCircle 438 282 'XP' '#0B74D1'
Draw-Text 'Career Progress' 546 268 24 '#5D6A77'
Draw-Text 'Qualified Plumber' 546 302 38 '#102033' 'Bold'
Draw-IconCircle 926 282 '*' '#FFC857'
Draw-Text 'Reputation' 1034 268 24 '#5D6A77'
Draw-Text '4.6' 1034 302 44 '#102033' 'Bold'

Draw-Text 'Upgrade your plumbing business' 68 475 48 '#102033' 'Bold'
Draw-Text 'One-time packs unlock real training content, tools, and job categories. Purchases are restored through StoreKit.' 68 542 28 '#53606D' 'Regular' 1120

Draw-Text 'Business Upgrades' 68 660 34 '#102033' 'Bold'
Draw-RoundRect 68 720 552 250 26 '#FFFFFF' '#DDE6EF'
Draw-IconCircle 104 760 'V' '#0B74D1'
Draw-Text 'Branded Van Wrap' 210 756 31 '#102033' 'Bold'
Draw-Text '+0.1 reputation on perfect jobs' 210 806 24 '#53606D' 'Regular' 350
Draw-RoundRect 210 880 170 54 27 '#EAF6FF' '#A5D8FF'
Draw-Text 'Owned' 258 890 24 '#0B74D1' 'Bold'

Draw-RoundRect 670 720 552 250 26 '#FFFFFF' '#DDE6EF'
Draw-IconCircle 706 760 'B' '#F97316'
Draw-Text 'Business Owner Desk' 812 756 31 '#102033' 'Bold'
Draw-Text 'Unlocks owner-mode decision jobs' 812 806 24 '#53606D' 'Regular' 350
Draw-RoundRect 812 880 160 54 27 '#FFF3E8' '#FDBA74'
Draw-Text 'Buy' 869 890 24 '#C2410C' 'Bold'

Draw-Text 'Expansion Packs' 68 1050 38 '#102033' 'Bold'
$packs = @(
    @{ Title = 'Advanced Tool Pack'; Desc = 'Unlock specialist tools: thermal camera, press tool, drain camera, and pipe freeze kit.'; Price = '$7.99'; Icon = 'T'; Color = '#0B74D1' },
    @{ Title = 'City Expansion Pack'; Desc = 'Adds dense apartment, restaurant, and mixed-use commercial plumbing jobs.'; Price = '$9.99'; Icon = 'C'; Color = '#F97316' },
    @{ Title = 'Emergency Jobs Pack'; Desc = 'Unlock urgent burst pipe, callout, isolation, and triage scenarios.'; Price = '$5.99'; Icon = 'E'; Color = '#DC2626' },
    @{ Title = 'Business Owner Mode'; Desc = 'Adds quoting, scheduling, staffing, contract strategy, and owner challenges.'; Price = '$11.99'; Icon = 'B'; Color = '#102033' }
)

$y = 1115
foreach ($p in $packs) {
    Draw-RoundRect 68 $y 1154 312 28 '#FFFFFF' '#DDE6EF'
    Draw-IconCircle 108 ($y + 44) $p.Icon $p.Color
    Draw-Text $p.Title 224 ($y + 42) 36 '#102033' 'Bold'
    Draw-Text $p.Desc 224 ($y + 98) 27 '#53606D' 'Regular' 720
    Draw-Text 'Permanent unlock' 224 ($y + 190) 24 '#178A42' 'Bold'
    Draw-Text 'Works offline after purchase' 530 ($y + 190) 24 '#178A42' 'Bold'
    Draw-RoundRect 978 ($y + 92) 190 74 37 '#0B74D1' '#0B74D1'
    Draw-Text $p.Price 1032 ($y + 110) 30 '#FFFFFF' 'Bold'
    Draw-Text 'One-time purchase' 928 ($y + 182) 24 '#53606D'
    $y += 346
}

Draw-RoundRect 68 2520 1154 145 26 '#EAF6FF' '#A5D8FF'
Draw-Text 'Restore Purchases' 112 2550 30 '#0B74D1' 'Bold'
Draw-Text 'All purchases are handled by StoreKit. No account is required in PipeBoss AI.' 112 2596 25 '#53606D' 'Regular' 980
Draw-Text 'Educational training simulation only. Always follow local regulations for real-world plumbing work.' 68 2712 22 '#71808F' 'Regular' 1150

$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Get-Item $path | Select-Object FullName, Length
