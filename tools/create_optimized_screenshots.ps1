param([string]$OnlyLocale)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$root = Get-Location
$captions = Get-Content -LiteralPath 'tools/duo-captions.json' -Raw -Encoding UTF8 | ConvertFrom-Json
$outputRoot = Join-Path $root 'AppStoreAssets/Screenshots/Optimized-1.0.2'
$sourceRoot = Join-Path $root 'AppStoreAssets/SourceCaptures/1.0.2'
$screens = @('dashboard','diagnosis','tools','result')
$names = @('01-plumbing-training','02-fault-diagnosis','03-plumbing-tools','04-repair-feedback')
$displays = @(
    @{ Key='APP_IPHONE_65'; Width=1242; Height=2688; Source='iPhone'; Suffix='' },
    @{ Key='APP_IPHONE_67'; Width=1290; Height=2796; Source='iPhone'; Suffix='' },
    @{ Key='APP_IPAD_PRO_3GEN_129'; Width=2048; Height=2732; Source='iPad'; Suffix='' },
    @{ Key='APP_IPHONE_DUO'; Width=1398; Height=2034; Source='iPhone'; Suffix='-outer' },
    @{ Key='APP_IPHONE_DUO'; Width=2007; Height=2853; Source='iPad'; Suffix='-inner' }
)
function Paint-Text($graphics,$text,$rect,$size,$color,$bold,$rtl) {
    $style = if ($bold) { [Drawing.FontStyle]::Bold } else { [Drawing.FontStyle]::Regular }
    $format = [Drawing.StringFormat]::new()
    $format.Alignment = [Drawing.StringAlignment]::Center
    $format.LineAlignment = [Drawing.StringAlignment]::Center
    if ($rtl) { $format.FormatFlags = [Drawing.StringFormatFlags]::DirectionRightToLeft }
    do {
        $font = [Drawing.Font]::new('Segoe UI',[float]$size,$style,[Drawing.GraphicsUnit]::Pixel)
        $measure = $graphics.MeasureString($text,$font,[int]$rect.Width,$format)
        if ($measure.Height -le $rect.Height) { break }
        $font.Dispose()
        $size -= 1
    } while ($size -gt 20)
    if ($measure.Height -gt $rect.Height) { throw "Caption cannot fit: $text" }
    $brush = [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml($color))
    $graphics.DrawString($text,$font,$brush,$rect,$format)
    $brush.Dispose(); $font.Dispose(); $format.Dispose()
}
$manifest = [Collections.Generic.List[object]]::new()
foreach ($property in $captions.PSObject.Properties) {
    $locale = $property.Name
    if ($OnlyLocale -and $locale -ne $OnlyLocale) { continue }
    $copy = $property.Value
    foreach ($display in $displays) {
        $directory = Join-Path $outputRoot "$locale/$($display.Key)"
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        for ($index=0; $index -lt 4; $index++) {
            $w=$display.Width; $h=$display.Height
            $scale=$w/1398.0
            $bitmap=[Drawing.Bitmap]::new($w,$h,[Drawing.Imaging.PixelFormat]::Format24bppRgb)
            $g=[Drawing.Graphics]::FromImage($bitmap)
            $g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.TextRenderingHint=[Drawing.Text.TextRenderingHint]::AntiAliasGridFit
            $g.Clear([Drawing.ColorTranslator]::FromHtml('#EDF5FC'))
            $header=[int]($h*0.215)
            $navy=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#081D36'))
            $g.FillRectangle($navy,0,0,$w,$header)
            $accent=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#F97316'))
            $g.FillRectangle($accent,0,$header-([int](8*$scale)),$w,[int](8*$scale))
            Paint-Text $g 'PipeBoss AI' ([Drawing.RectangleF]::new(60*$scale,26*$scale,$w-120*$scale,48*$scale)) (34*$scale) '#B5D8FF' $true $false
            Paint-Text $g $copy.shots[$index].title ([Drawing.RectangleF]::new(66*$scale,82*$scale,$w-132*$scale,$header*0.47)) (78*$scale) '#FFFFFF' $true ([bool]$copy.rtl)
            Paint-Text $g $copy.shots[$index].subtitle ([Drawing.RectangleF]::new(80*$scale,$header*0.73,$w-160*$scale,$header*0.22)) (31*$scale) '#C7E1FF' $false ([bool]$copy.rtl)
            $sourcePath=Join-Path $sourceRoot "$($display.Source)/$($screens[$index]).png"
            $source=[Drawing.Image]::FromFile($sourcePath)
            $footerHeight=[int](72*$scale)
            $margin=[int](28*$scale)
            $availableH=$h-$header-$footerHeight-2*$margin
            $availableW=$w-2*$margin
            $factor=[Math]::Min($availableW/$source.Width,$availableH/$source.Height)
            $imageW=[int]($source.Width*$factor); $imageH=[int]($source.Height*$factor)
            $imageX=[int](($w-$imageW)/2); $imageY=$header+$margin
            $shadow=[Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#D3E2EE'))
            $g.FillRectangle($shadow,$imageX-8*$scale,$imageY-8*$scale,$imageW+16*$scale,$imageH+16*$scale)
            # Compose a new marketing canvas around an unaltered, complete native capture.
            $g.DrawImage($source,[Drawing.Rectangle]::new($imageX,$imageY,$imageW,$imageH))
            Paint-Text $g $copy.footer ([Drawing.RectangleF]::new(36*$scale,$h-$footerHeight,$w-72*$scale,$footerHeight)) (23*$scale) '#40546D' $false ([bool]$copy.rtl)
            $fileName="$($names[$index])$($display.Suffix)-native.png"
            $file=Join-Path $directory $fileName
            $bitmap.Save($file,[Drawing.Imaging.ImageFormat]::Png)
            $manifest.Add(@{locale=$locale;displayType=$display.Key;fileName=$fileName;path=$file;source=$sourcePath;width=$w;height=$h;sha256=(Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLower()})
            $source.Dispose(); $g.Dispose(); $bitmap.Dispose(); $navy.Dispose(); $accent.Dispose(); $shadow.Dispose()
        }
    }
    Write-Output "${locale}: 20 native marketing screenshots"
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $outputRoot 'manifest.json') -Encoding UTF8
