$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$root = Get-Location
$phoneDir = Join-Path $root 'AppStoreAssets\Screenshots\iPhone65'
$ipadDir = Join-Path $root 'AppStoreAssets\Screenshots\iPad129'
New-Item -ItemType Directory -Force -Path $phoneDir, $ipadDir | Out-Null

function New-Brush($hex) {
    New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($hex))
}

function New-PenC($hex, $width = 1) {
    New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml($hex), $width)
}

function Draw-RoundRect($g, $x, $y, $w, $h, $r, $fill, $stroke = $null, $strokeWidth = 2) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    if ($r -le 0) {
        $rect = [System.Drawing.RectangleF]::new([float]$x, [float]$y, [float]$w, [float]$h)
        if ($fill) { $g.FillRectangle((New-Brush $fill), $rect) }
        if ($stroke) { $g.DrawRectangle((New-PenC $stroke $strokeWidth), [float]$x, [float]$y, [float]$w, [float]$h) }
        return
    }

    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($fill) { $g.FillPath((New-Brush $fill), $path) }
    if ($stroke) { $g.DrawPath((New-PenC $stroke $strokeWidth), $path) }
    $path.Dispose()
}

function Draw-Text($g, $text, $x, $y, $size, $color = '#102033', $style = 'Regular', $maxWidth = 0, $maxHeight = 500, $align = 'Near') {
    $fontStyle = [System.Drawing.FontStyle]::Regular
    if ($style -eq 'Bold' -or $style -eq 'Semibold') { $fontStyle = [System.Drawing.FontStyle]::Bold }
    $font = New-Object System.Drawing.Font('Segoe UI', $size, $fontStyle, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Brush $color
    $format = New-Object System.Drawing.StringFormat
    if ($align -eq 'Center') { $format.Alignment = [System.Drawing.StringAlignment]::Center }
    if ($maxWidth -gt 0) {
        $g.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new([float]$x, [float]$y, [float]$maxWidth, [float]$maxHeight), $format)
    } else {
        $g.DrawString($text, $font, $brush, [float]$x, [float]$y)
    }
    $format.Dispose()
    $font.Dispose()
    $brush.Dispose()
}

function Draw-Header($g, $w, $title, $subtitle, $accent = '#F97316') {
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml('#F4F8FC'))
    Draw-RoundRect $g 0 0 $w 520 0 '#071B33'
    Draw-RoundRect $g 76 86 92 92 24 '#0B74D1'
    Draw-Text $g 'PB' 101 111 33 '#FFFFFF' 'Bold'
    Draw-Text $g 'PipeBoss AI' 190 86 46 '#FFFFFF' 'Bold'
    Draw-Text $g 'Plumbing training game' 190 140 25 '#B9D7F7'
    Draw-RoundRect $g ($w - 284) 94 205 58 29 $accent
    Draw-Text $g 'APP STORE' ($w - 246) 108 22 '#FFFFFF' 'Bold'
    Draw-Text $g $title 76 230 62 '#FFFFFF' 'Bold' ($w - 152) 160
    Draw-Text $g $subtitle 76 400 32 '#B9D7F7' 'Regular' ($w - 152) 88
}

function Draw-PhoneChrome($g, $x, $y, $w, $h, $title) {
    Draw-RoundRect $g $x $y $w $h 44 '#FFFFFF' '#D8E3EE' 3
    Draw-RoundRect $g $x $y $w 150 44 '#071B33'
    Draw-Text $g '9:41' ($x + 42) ($y + 36) 28 '#FFFFFF' 'Bold'
    Draw-Text $g $title ($x + 42) ($y + 88) 34 '#FFFFFF' 'Bold'
    Draw-RoundRect $g ($x + $w - 190) ($y + 48) 130 48 24 '#F97316'
    Draw-Text $g 'Level 8' ($x + $w - 161) ($y + 58) 21 '#FFFFFF' 'Bold'
}

function Draw-Badge($g, $x, $y, $text, $color = '#0B74D1') {
    Draw-RoundRect $g $x $y 190 54 27 '#EAF6FF' '#A5D8FF'
    Draw-Text $g $text ($x + 22) ($y + 13) 21 $color 'Bold'
}

function Draw-StatCard($g, $x, $y, $label, $value, $color) {
    Draw-RoundRect $g $x $y 300 170 26 '#FFFFFF' '#D8E3EE'
    Draw-RoundRect $g ($x + 26) ($y + 28) 56 56 18 $color
    Draw-Text $g $label ($x + 102) ($y + 30) 22 '#596675'
    Draw-Text $g $value ($x + 102) ($y + 68) 38 '#102033' 'Bold'
}

function Draw-PhoneScreen($path, $title, $subtitle, $screen, $accent) {
    $w = 1242
    $h = 2688
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    Draw-Header $g $w $title $subtitle $accent
    $x = 76
    $y = 610
    $sw = 1090
    $sh = 1870
    Draw-PhoneChrome $g $x $y $sw $sh $screen

    switch ($screen) {
        'Job Board' {
            Draw-Text $g 'Available Jobs' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            $jobs = @(
                @{T='Leaking pipe under sink'; D='Compression fitting, isolation valve, 12 min'; C='#0B74D1'; S='Ready'},
                @{T='Blocked drain'; D='Plunger, auger, trap inspection, 15 min'; C='#178A42'; S='Ready'},
                @{T='Low water pressure'; D='Check aerator, valve, pressure meter'; C='#F97316'; S='Ready'},
                @{T='Burst pipe emergency'; D='Emergency pack: isolate supply fast'; C='#DC2626'; S='Pro'}
            )
            $jy = $y + 292
            foreach ($job in $jobs) {
                Draw-RoundRect $g ($x + 52) $jy 986 185 30 '#FFFFFF' '#D8E3EE'
                Draw-RoundRect $g ($x + 90) ($jy + 45) 76 76 22 $job.C
                Draw-Text $g 'PB' ($x + 109) ($jy + 64) 26 '#FFFFFF' 'Bold'
                Draw-Text $g $job.T ($x + 196) ($jy + 38) 32 '#102033' 'Bold'
                Draw-Text $g $job.D ($x + 196) ($jy + 88) 23 '#596675' 'Regular' 560 70
                Draw-Badge $g ($x + 825) ($jy + 64) $job.S
                $jy += 218
            }
            Draw-RoundRect $g ($x + 52) ($y + 1278) 986 260 30 '#EAF6FF' '#A5D8FF'
            Draw-Text $g 'Each job includes symptoms, tools, time limit, diagnosis, repair choices, XP, coins, and a Master Plumber Tip.' ($x + 96) ($y + 1326) 28 '#0B3B66' 'Bold' 860 160
        }
        'Diagnosis' {
            Draw-Text $g 'Customer Complaint' ($x + 52) ($y + 205) 40 '#102033' 'Bold'
            Draw-RoundRect $g ($x + 52) ($y + 280) 986 230 30 '#FFFFFF' '#D8E3EE'
            Draw-Text $g 'Upstairs taps run slowly after recent pipe work. Customer hears air noise when the pump starts.' ($x + 96) ($y + 330) 30 '#102033' 'Regular' 860 120
            Draw-Text $g 'Choose the best diagnosis' ($x + 52) ($y + 595) 38 '#102033' 'Bold'
            $opts = @(
                @{T='Partially closed service valve'; C='#FFFFFF'; F='#D8E3EE'; Text='#102033'},
                @{T='Airlock or restriction in pipework'; C='#0B74D1'; F='#0B74D1'; Text='#FFFFFF'},
                @{T='Blocked waste trap'; C='#FFFFFF'; F='#D8E3EE'; Text='#102033'},
                @{T='Incorrect toilet float setting'; C='#FFFFFF'; F='#D8E3EE'; Text='#102033'}
            )
            $oy = $y + 670
            foreach ($opt in $opts) {
                Draw-RoundRect $g ($x + 52) $oy 986 118 28 $opt.C $opt.F
                Draw-Text $g $opt.T ($x + 96) ($oy + 37) 30 $opt.Text 'Bold'
                $oy += 150
            }
            Draw-RoundRect $g ($x + 52) ($y + 1328) 986 210 30 '#FFF7ED' '#FDBA74'
            Draw-Text $g 'Haptic feedback and practical tips reinforce correct decisions after each repair.' ($x + 96) ($y + 1382) 28 '#9A3412' 'Bold' 840 110
        }
        'Tools' {
            Draw-Text $g 'Pick the right kit' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            $tools = @(
                @{T='Pipe Cutter'; D='Clean copper and plastic cuts'; C='#0B74D1'},
                @{T='Pressure Gauge'; D='Read system pressure safely'; C='#F97316'},
                @{T='Inspection Camera'; D='Find hidden drainage faults'; C='#178A42'},
                @{T='Freeze Kit'; D='Advanced pipe isolation'; C='#7C3AED'},
                @{T='Drain Auger'; D='Clear deeper blockages'; C='#DC2626'},
                @{T='Thermal Camera'; D='Trace heating problems'; C='#0F766E'}
            )
            $tx = $x + 52
            $ty = $y + 300
            for ($i = 0; $i -lt $tools.Count; $i++) {
                $tool = $tools[$i]
                $cx = $tx + (($i % 2) * 510)
                $cy = $ty + ([Math]::Floor($i / 2) * 300)
                Draw-RoundRect $g $cx $cy 476 250 30 '#FFFFFF' '#D8E3EE'
                Draw-RoundRect $g ($cx + 34) ($cy + 34) 82 82 24 $tool.C
                Draw-Text $g 'T' ($cx + 61) ($cy + 48) 38 '#FFFFFF' 'Bold'
                Draw-Text $g $tool.T ($cx + 34) ($cy + 136) 29 '#102033' 'Bold'
                Draw-Text $g $tool.D ($cx + 34) ($cy + 180) 22 '#596675' 'Regular' 380 60
            }
            Draw-RoundRect $g ($x + 52) ($y + 1280) 986 250 30 '#071B33'
            Draw-Text $g 'Unlock advanced tools as your virtual plumbing business grows.' ($x + 96) ($y + 1340) 31 '#FFFFFF' 'Bold' 850 100
        }
        'Repair Decision' {
            Draw-Text $g 'Select the repair' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            Draw-RoundRect $g ($x + 52) ($y + 285) 986 300 30 '#FFFFFF' '#D8E3EE'
            Draw-Text $g 'Symptom checklist' ($x + 96) ($y + 333) 32 '#102033' 'Bold'
            Draw-Text $g "- Drip under sink after tap use`n- Compression joint damp`n- Isolation valve accessible" ($x + 96) ($y + 392) 28 '#596675' 'Regular' 820 150
            $repairs = @('Tighten and remake compression joint', 'Replace boiler expansion vessel', 'Install larger waste pipe')
            $ry = $y + 670
            foreach ($repair in $repairs) {
                $selected = $repair.StartsWith('Tighten')
                Draw-RoundRect $g ($x + 52) $ry 986 125 28 $(if ($selected) { '#0B74D1' } else { '#FFFFFF' }) $(if ($selected) { '#0B74D1' } else { '#D8E3EE' })
                Draw-Text $g $repair ($x + 96) ($ry + 38) 28 $(if ($selected) { '#FFFFFF' } else { '#102033' }) 'Bold'
                $ry += 158
            }
            Draw-RoundRect $g ($x + 52) ($y + 1245) 986 290 30 '#ECFDF5' '#86EFAC'
            Draw-Text $g '+120 XP  +80 coins  4.8 rating' ($x + 96) ($y + 1298) 36 '#166534' 'Bold'
            Draw-Text $g 'Wrong decisions reduce time, profit, or reputation and can require rework.' ($x + 96) ($y + 1370) 28 '#166534' 'Regular' 830 100
        }
        'Career' {
            Draw-Text $g 'Career Progress' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            Draw-StatCard $g ($x + 52) ($y + 300) 'XP' '8,420' '#0B74D1'
            Draw-StatCard $g ($x + 395) ($y + 300) 'Coins' '1,840' '#F97316'
            Draw-StatCard $g ($x + 738) ($y + 300) 'Rating' '4.6' '#FFC857'
            Draw-RoundRect $g ($x + 52) ($y + 585) 986 280 30 '#FFFFFF' '#D8E3EE'
            Draw-Text $g 'Qualified Plumber' ($x + 96) ($y + 642) 42 '#102033' 'Bold'
            Draw-Text $g 'Next: Master Plumber' ($x + 96) ($y + 700) 28 '#596675'
            Draw-RoundRect $g ($x + 96) ($y + 775) 800 38 19 '#E5EDF5'
            Draw-RoundRect $g ($x + 96) ($y + 775) 560 38 19 '#0B74D1'
            Draw-Text $g 'Career ladder' ($x + 52) ($y + 970) 36 '#102033' 'Bold'
            $levels = @('Apprentice', 'Junior Plumber', 'Qualified Plumber', 'Master Plumber', 'Business Owner')
            $ly = $y + 1040
            foreach ($level in $levels) {
                Draw-RoundRect $g ($x + 92) $ly 36 36 18 $(if ($level -eq 'Qualified Plumber') { '#F97316' } else { '#0B74D1' })
                Draw-Text $g $level ($x + 160) ($ly - 6) 30 '#102033' 'Bold'
                $ly += 90
            }
        }
        'Business' {
            Draw-Text $g 'Grow the business' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            $upgrades = @(
                @{T='Better Van'; D='Finish jobs faster'; C='#0B74D1'},
                @{T='Apprentice Helper'; D='Boost job capacity'; C='#178A42'},
                @{T='Commercial Contracts'; D='Unlock larger jobs'; C='#F97316'},
                @{T='Emergency Response'; D='Premium urgent work'; C='#DC2626'}
            )
            $uy = $y + 300
            foreach ($upgrade in $upgrades) {
                Draw-RoundRect $g ($x + 52) $uy 986 185 30 '#FFFFFF' '#D8E3EE'
                Draw-RoundRect $g ($x + 96) ($uy + 48) 76 76 22 $upgrade.C
                Draw-Text $g 'U' ($x + 122) ($uy + 66) 30 '#FFFFFF' 'Bold'
                Draw-Text $g $upgrade.T ($x + 205) ($uy + 42) 34 '#102033' 'Bold'
                Draw-Text $g $upgrade.D ($x + 205) ($uy + 96) 25 '#596675'
                Draw-Badge $g ($x + 805) ($uy + 66) 'Upgrade'
                $uy += 225
            }
            Draw-RoundRect $g ($x + 52) ($y + 1260) 986 255 30 '#071B33'
            Draw-Text $g 'From apprentice jobs to business owner mode, every good decision compounds.' ($x + 96) ($y + 1322) 31 '#FFFFFF' 'Bold' 840 110
        }
        'Learning Cards' {
            Draw-Text $g 'Master Plumber Tips' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            $cards = @('Safety basics', 'Pipe materials', 'Fittings', 'Pressure', 'Drainage', 'Heating basics', 'Customer communication')
            $cy = $y + 300
            foreach ($card in $cards) {
                Draw-RoundRect $g ($x + 52) $cy 986 118 28 '#FFFFFF' '#D8E3EE'
                Draw-Text $g $card ($x + 96) ($cy + 36) 31 '#102033' 'Bold'
                Draw-Badge $g ($x + 805) ($cy + 33) 'Card'
                $cy += 142
            }
            Draw-RoundRect $g ($x + 52) ($y + 1340) 986 200 30 '#EAF6FF' '#A5D8FF'
            Draw-Text $g 'Simple, practical learning after every job. No unsafe real-world repair claims.' ($x + 96) ($y + 1392) 29 '#0B3B66' 'Bold' 840 100
        }
        'PipeBoss Store' {
            Draw-Text $g 'Go deeper with Pro' ($x + 52) ($y + 205) 42 '#102033' 'Bold'
            Draw-RoundRect $g ($x + 52) ($y + 295) 986 320 34 '#071B33'
            Draw-Text $g 'PipeBoss Pro' ($x + 96) ($y + 350) 46 '#FFFFFF' 'Bold'
            Draw-Text $g 'Unlimited jobs, advanced scenarios, boiler and heating modules, commercial work, exam quizzes, mentor hints, and analytics.' ($x + 96) ($y + 418) 28 '#B9D7F7' 'Regular' 820 130
            Draw-RoundRect $g ($x + 96) ($y + 532) 275 58 29 '#F97316'
            Draw-Text $g 'Subscribe' ($x + 176) ($y + 545) 24 '#FFFFFF' 'Bold'
            $packs = @('Emergency Jobs Pack', 'Advanced Tool Pack', 'City Expansion Pack', 'Business Owner Mode')
            $py = $y + 700
            foreach ($pack in $packs) {
                Draw-RoundRect $g ($x + 52) $py 986 135 28 '#FFFFFF' '#D8E3EE'
                Draw-Text $g $pack ($x + 96) ($py + 42) 30 '#102033' 'Bold'
                Draw-Badge $g ($x + 805) ($py + 40) 'Pack'
                $py += 165
            }
            Draw-Text $g 'Free users can still play beginner jobs and learn core plumbing concepts.' ($x + 52) ($y + 1430) 26 '#596675' 'Regular' 930 80
        }
    }

    Draw-Text $g 'Educational simulation only. Always follow local regulations for real plumbing work.' 76 2550 24 '#71808F' 'Regular' 1040 60 'Center'
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

function Draw-iPadScreen($path, $title, $subtitle, $screen, $accent) {
    $w = 2048
    $h = 2732
    $bmp = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    Draw-Header $g $w $title $subtitle $accent
    Draw-RoundRect $g 92 630 1864 1740 44 '#FFFFFF' '#D8E3EE' 3
    Draw-RoundRect $g 92 630 1864 150 44 '#071B33'
    Draw-Text $g $screen 150 678 46 '#FFFFFF' 'Bold'
    Draw-RoundRect $g 1650 680 220 54 27 '#F97316'
    Draw-Text $g 'Level 8' 1720 692 24 '#FFFFFF' 'Bold'

    if ($screen -eq 'Training Dashboard') {
        Draw-Text $g 'Run the day like a plumber' 150 860 54 '#102033' 'Bold'
        Draw-Text $g 'Inspect faults, choose tools, diagnose causes, and grow a virtual plumbing business.' 150 930 30 '#596675' 'Regular' 1500 90
        Draw-StatCard $g 150 1080 'XP' '8,420' '#0B74D1'
        Draw-StatCard $g 500 1080 'Coins' '1,840' '#F97316'
        Draw-StatCard $g 850 1080 'Rating' '4.6' '#FFC857'
        Draw-StatCard $g 1200 1080 'Tools' '18' '#178A42'
        Draw-Text $g 'Next Jobs' 150 1370 42 '#102033' 'Bold'
        Draw-RoundRect $g 150 1450 790 170 28 '#FFFFFF' '#D8E3EE'
        Draw-Text $g 'Leaking pipe under sink' 200 1492 34 '#102033' 'Bold'
        Draw-Text $g 'Beginner - 12 min - Compression fitting' 200 1544 25 '#596675'
        Draw-RoundRect $g 1020 1450 790 170 28 '#FFFFFF' '#D8E3EE'
        Draw-Text $g 'Commercial maintenance' 1070 1492 34 '#102033' 'Bold'
        Draw-Text $g 'Advanced - pressure and drainage' 1070 1544 25 '#596675'
    } elseif ($screen -eq 'Diagnosis Lab') {
        Draw-Text $g 'Customer says the upstairs taps run slowly.' 150 860 48 '#102033' 'Bold' 1600 100
        Draw-RoundRect $g 150 1020 820 560 32 '#FFFFFF' '#D8E3EE'
        Draw-Text $g 'Symptoms' 205 1080 38 '#102033' 'Bold'
        Draw-Text $g "- Low upstairs flow`n- Air noise in pipework`n- No visible leak`n- Pump starts normally" 205 1160 30 '#596675' 'Regular' 700 250
        Draw-RoundRect $g 1040 1020 770 560 32 '#FFFFFF' '#D8E3EE'
        Draw-Text $g 'Diagnosis' 1095 1080 38 '#102033' 'Bold'
        Draw-RoundRect $g 1095 1160 620 90 24 '#0B74D1'
        Draw-Text $g 'Airlock or restriction' 1140 1182 30 '#FFFFFF' 'Bold'
        Draw-RoundRect $g 1095 1280 620 90 24 '#FFFFFF' '#D8E3EE'
        Draw-Text $g 'Blocked waste trap' 1140 1302 30 '#102033' 'Bold'
    } elseif ($screen -eq 'Tool Inventory') {
        $names = @('Pipe Cutter', 'Pressure Gauge', 'Drain Auger', 'Thermal Camera', 'Inspection Camera', 'Freeze Kit')
        $colors = @('#0B74D1', '#F97316', '#178A42', '#7C3AED', '#DC2626', '#0F766E')
        for ($i = 0; $i -lt $names.Count; $i++) {
            $col = $i % 3
            $row = [Math]::Floor($i / 3)
            $cx = 150 + ($col * 575)
            $cy = 900 + ($row * 420)
            Draw-RoundRect $g $cx $cy 505 320 32 '#FFFFFF' '#D8E3EE'
            Draw-RoundRect $g ($cx + 40) ($cy + 42) 94 94 26 $colors[$i]
            Draw-Text $g 'T' ($cx + 72) ($cy + 60) 42 '#FFFFFF' 'Bold'
            Draw-Text $g $names[$i] ($cx + 40) ($cy + 165) 34 '#102033' 'Bold'
            Draw-Text $g 'Unlock and apply the right tool for each realistic scenario.' ($cx + 40) ($cy + 218) 25 '#596675' 'Regular' 410 80
        }
    } else {
        Draw-Text $g 'Grow from apprentice to business owner.' 150 860 54 '#102033' 'Bold'
        Draw-Text $g 'Invest job profits into vans, apprentices, advanced tools, city expansion, and commercial plumbing work.' 150 940 32 '#596675' 'Regular' 1500 110
        $items = @('Better Van', 'Apprentice Helper', 'Commercial Contracts', 'Emergency Response')
        $iy = 1120
        foreach ($item in $items) {
            Draw-RoundRect $g 150 $iy 1660 175 30 '#FFFFFF' '#D8E3EE'
            Draw-Text $g $item 215 ($iy + 45) 38 '#102033' 'Bold'
            Draw-Badge $g 1540 ($iy + 58) 'Upgrade'
            $iy += 215
        }
    }

    Draw-Text $g 'Educational simulation only. Always follow local regulations for real plumbing work.' 92 2550 28 '#71808F' 'Regular' 1864 80 'Center'
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$phoneScreens = @(
    @{File='01-real-jobs.png'; Title='Learn Plumbing With Real Jobs'; Subtitle='Train on leaks, drains, pressure faults, heating issues, and emergencies.'; Screen='Job Board'; Accent='#0B74D1'},
    @{File='02-diagnose-faults.png'; Title='Diagnose Faults Like A Pro'; Subtitle='Read symptoms, inspect clues, and choose the most likely plumbing cause.'; Screen='Diagnosis'; Accent='#F97316'},
    @{File='03-tool-inventory.png'; Title='Choose The Right Tools'; Subtitle='Unlock and use practical plumbing tools across beginner and advanced jobs.'; Screen='Tools'; Accent='#178A42'},
    @{File='04-repair-decisions.png'; Title='Make The Repair Call'; Subtitle='Select the best fix, avoid costly rework, and earn higher customer ratings.'; Screen='Repair Decision'; Accent='#0B74D1'},
    @{File='05-career-progress.png'; Title='Level Up From Apprentice'; Subtitle='Earn XP, coins, reputation, and unlock the path to master plumber.'; Screen='Career'; Accent='#F97316'},
    @{File='06-business-upgrades.png'; Title='Build Your Plumbing Business'; Subtitle='Upgrade vans, tools, helpers, contracts, and business owner mode.'; Screen='Business'; Accent='#071B33'},
    @{File='07-learning-cards.png'; Title='Learn Practical Safety Tips'; Subtitle='Unlock simple training cards after jobs, quizzes, and major repairs.'; Screen='Learning Cards'; Accent='#178A42'},
    @{File='08-pipeboss-pro.png'; Title='Go Pro For Advanced Training'; Subtitle='Unlock unlimited jobs, boiler modules, commercial work, and exam-style quizzes.'; Screen='PipeBoss Store'; Accent='#F97316'}
)

foreach ($shot in $phoneScreens) {
    Draw-PhoneScreen (Join-Path $phoneDir $shot.File) $shot.Title $shot.Subtitle $shot.Screen $shot.Accent
}

$ipadScreens = @(
    @{File='01-ipad-dashboard.png'; Title='A Bigger Training Dashboard'; Subtitle='Track jobs, XP, tools, and business progress on iPad.'; Screen='Training Dashboard'; Accent='#0B74D1'},
    @{File='02-ipad-diagnosis.png'; Title='Practice Diagnosis On iPad'; Subtitle='Use clear symptoms and repair choices for classroom-style learning.'; Screen='Diagnosis Lab'; Accent='#F97316'},
    @{File='03-ipad-tools.png'; Title='Build A Better Tool Kit'; Subtitle='Unlock practical tools and apply them to realistic scenarios.'; Screen='Tool Inventory'; Accent='#178A42'},
    @{File='04-ipad-business.png'; Title='Grow The Plumbing Business'; Subtitle='Invest rewards into upgrades, contracts, and advanced training packs.'; Screen='Business Upgrades'; Accent='#071B33'}
)

foreach ($shot in $ipadScreens) {
    Draw-iPadScreen (Join-Path $ipadDir $shot.File) $shot.Title $shot.Subtitle $shot.Screen $shot.Accent
}

Get-ChildItem -File $phoneDir, $ipadDir | Select-Object FullName, Length
