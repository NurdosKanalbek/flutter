# Original geometric workshop illustration; no downloaded images or packages.
Add-Type -AssemblyName System.Drawing
$banner = [System.Drawing.Bitmap]::new(1200, 400)
$canvas = [System.Drawing.Graphics]::FromImage($banner)
$canvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$canvas.Clear([System.Drawing.Color]::FromArgb(224, 232, 242))
$gridPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(195, 209, 226), 2)
for ($x = 0; $x -le 1200; $x += 40) { $canvas.DrawLine($gridPen, $x, 0, $x, 400) }
for ($y = 0; $y -le 400; $y += 40) { $canvas.DrawLine($gridPen, 0, $y, 1200, $y) }
$accent = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(93, 119, 161))
$warm = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(181, 144, 106))
$ink = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(79, 96, 124), 12)
$canvas.FillEllipse($accent, 70, 80, 190, 190)
$canvas.FillRectangle($warm, 920, 140, 200, 140)
$canvas.DrawRectangle($ink, 470, 90, 210, 160)
$canvas.DrawLine($ink, 575, 250, 575, 290)
$canvas.DrawLine($ink, 515, 290, 635, 290)
$canvas.DrawLines($ink, [System.Drawing.Point[]]@(
  [System.Drawing.Point]::new(360, 130), [System.Drawing.Point]::new(300, 190),
  [System.Drawing.Point]::new(360, 250)))
$canvas.DrawLines($ink, [System.Drawing.Point[]]@(
  [System.Drawing.Point]::new(800, 130), [System.Drawing.Point]::new(860, 190),
  [System.Drawing.Point]::new(800, 250)))
$assetPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'assets\maker_banner.png'
[System.IO.Directory]::CreateDirectory((Split-Path $assetPath -Parent)) | Out-Null
$banner.Save($assetPath, [System.Drawing.Imaging.ImageFormat]::Png)
foreach ($resource in @($canvas, $banner, $gridPen, $accent, $warm, $ink)) { $resource.Dispose() }
