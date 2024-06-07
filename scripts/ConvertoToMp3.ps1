$startFolder = ""

Get-ChildItem -Path $startFolder -Filter *.mp4 -Recurse -File | ForEach-Object {
    Write-Host ">>> Compressing ["($_)"]" -ForegroundColor Green

    $newFile = [System.IO.Path]::GetDirectoryName($_) + `
        "\" + `
        [System.IO.Path]::GetFileNameWithoutExtension($_) + `
        ".mp3"
    
    Write-Host ">>> New file ["($newFile)"]" -ForegroundColor Green
    Write-Host ""
    $command = "ffmpeg -v quiet -stats -i ""$($_)"" -b:a 128K  ""$newFile"""

    cmd /c $command

    Write-Host ">>> ["($newFile)"] DONE!!" -ForegroundColor Green
    Write-Host ""
}

Write-Host ">>> ALL DONE!!" -ForegroundColor Green