$startFolder = ""

Get-ChildItem -Path $startFolder -Filter *.mkv -Recurse -File | ForEach-Object {
    Write-Host ">>> Compressing ["($_)"]" -ForegroundColor Green

    $newFile = [System.IO.Path]::GetDirectoryName($_) + `
        "\" + `
        [System.IO.Path]::GetFileNameWithoutExtension($_) + `
        ".mp4"
    
    Write-Host ">>> New file ["($newFile)"]" -ForegroundColor Green
    Write-Host ""
    $command = "ffmpeg -v quiet -stats -i ""$($_)"" -c copy ""$newFile"""
    # Write-Host $command

    cmd /c $command

    Write-Host ">>> ["($newFile)"] DONE!!" -ForegroundColor Green
    Write-Host ""
}

Write-Host ">>> ALL DONE!!" -ForegroundColor Green