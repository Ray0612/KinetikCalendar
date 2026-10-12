# Draws icon.ico: a dark calendar page with a red header and coloured event dots (Google blue, Outlook teal, iCloud red).
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'

function RoundRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $p.AddArc($x, $y, $d, $d, 180, 90); $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90); $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $p.CloseFigure(); return $p
}

function Png([int]$s) {
    $b = New-Object System.Drawing.Bitmap $s, $s
    $g = [System.Drawing.Graphics]::FromImage($b)
    $g.SmoothingMode = 'AntiAlias'; $g.Clear([System.Drawing.Color]::Transparent)
    $m = [Math]::Max(0.5, $s * 0.06); $w = $s - 2 * $m; $r = $s * 0.2
    $body = RoundRect $m $m $w $w $r
    $g.FillPath((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 34, 34, 40))), $body)
    $g.SetClip($body)
    $g.FillRectangle((New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 240, 88, 88))), $m, $m, $w, $w * 0.27)
    $g.ResetClip()
    $cols = @([System.Drawing.Color]::FromArgb(96, 150, 250), [System.Drawing.Color]::FromArgb(40, 190, 200), [System.Drawing.Color]::FromArgb(250, 104, 96), [System.Drawing.Color]::FromArgb(220, 220, 228))
    $n = 3; $top = $m + $w * 0.38; $cell = $w * 0.62 / $n; $dot = $cell * 0.62
    for ($i = 0; $i -lt $n; $i++) { for ($j = 0; $j -lt $n; $j++) {
        $c = $cols[($i + $j * 2) % 4]
        $x = $m + $w * 0.19 + $i * $cell + ($cell - $dot) / 2; $y = $top + $j * $cell * 0.92 + ($cell - $dot) / 2
        $g.FillEllipse((New-Object System.Drawing.SolidBrush $c), [float]$x, [float]$y, [float]$dot, [float]$dot)
    } }
    $g.Dispose()
    $ms = New-Object IO.MemoryStream; $b.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
    return , $ms.ToArray()
}

$sizes = 16, 24, 32, 48, 256
$imgs = $sizes | ForEach-Object { , (Png $_) }
$out = New-Object IO.MemoryStream
$bw = New-Object IO.BinaryWriter $out
$bw.Write([uint16]0); $bw.Write([uint16]1); $bw.Write([uint16]$sizes.Count)
$offset = 6 + 16 * $sizes.Count
for ($i = 0; $i -lt $sizes.Count; $i++) {
    $s = $sizes[$i]; $len = $imgs[$i].Length
    $bw.Write([byte]($s % 256)); $bw.Write([byte]($s % 256)); $bw.Write([byte]0); $bw.Write([byte]0)
    $bw.Write([uint16]1); $bw.Write([uint16]32); $bw.Write([uint32]$len); $bw.Write([uint32]$offset)
    $offset += $len
}
foreach ($img in $imgs) { $bw.Write($img) }
[IO.File]::WriteAllBytes((Join-Path $PSScriptRoot 'icon.ico'), $out.ToArray())
Write-Output "Wrote icon.ico"
