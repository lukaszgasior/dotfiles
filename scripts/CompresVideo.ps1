$startFolder = ""

Get-ChildItem -Path $startFolder -Filter *.mp4 -Recurse -File | ForEach-Object {
    Write-Host ">>> Compressing ["($_)"]" -ForegroundColor Green

    $newFile = [System.IO.Path]::GetDirectoryName($_) + `
        "\" + `
        [System.IO.Path]::GetFileNameWithoutExtension($_) + `
        "_compressed" + `
        [System.IO.Path]::GetExtension($_)
    
    Write-Host ">>> New file ["($newFile)"]" -ForegroundColor Green

    if (Test-Path -Path "$newFile") {
        Write-Host ">>> Compressed file already exists. Skip compression" -ForegroundColor Yellow
        return
    }

    if ([System.IO.Path]::GetFileNameWithoutExtension($_) -match '_compressed$') {
        Write-Host ">>> File already compressed. Skip compression" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    $command = "ffmpeg -v quiet -stats -i ""$($_)"" -vcodec libx265 -crf 28 ""$newFile"""

    cmd /c $command

    Write-Host ">>> ["($newFile)"] DONE!!" -ForegroundColor Green
    Write-Host ""
}

Write-Host ">>> ALL DONE!!" -ForegroundColor Green