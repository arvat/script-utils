$exportPath = Join-Path $PSScriptRoot "export"
New-Item -ItemType Directory -Path $exportPath -Force | Out-Null

Get-ChildItem -LiteralPath $PSScriptRoot -File | Where-Object { $_.Extension -match '^\.(flac|mp3)$' } | ForEach-Object {
    Write-Host "Processing: $($_.Name)" -ForegroundColor Cyan
    & ffmpeg -hide_banner -i $_.FullName `
             -c:v mjpeg -disposition:v attached_pic `
             -c:a libfdk_aac -b:a 128k -ac 2 `
             -y (Join-Path $exportPath "$($_.BaseName).m4a")
}

Write-Host "Done." -ForegroundColor Green
Read-Host "Press Enter to close"