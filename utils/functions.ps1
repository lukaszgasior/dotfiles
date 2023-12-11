function StowFile([String]$link, [String]$target) {
    $file = Get-Item $link -ErrorAction SilentlyContinue

    if ($file) {
        if ($file.LinkType -ne "SymbolicLink") {
            Write-Error "[!] $($file.FullName) already exists and is not a symbolic link"
            return
        }
        elseif ($file.Target -ne $target) {
            Write-Error "[!] $($file.FullName) already exists and points to '$($file.Target)', it should point to '$target'"
            return
        }
        else {
            Write-Output "[!] $($file.FullName) already linked"
            return
        }
    }
    else {
        $folder = Split-Path $link
        if (-not (Test-Path $folder)) {
            Write-Output "[i] Creating folder $folder"
            [void](New-Item -Type Directory -Path $folder)
        }
    }

    Write-Output "[i] Creating link $link to $target"
    [void]((New-Item -Path $link -ItemType SymbolicLink -Value $target -ErrorAction Continue).Target)
}
    
function UnstowFile([String]$file) {
    if (Test-Path "$file") {
        Remove-Item "$file" -Force
        Write-Output "[i] Removed $file"
    }
    else {
        Write-Output "[i] File $file is already removed, consider removing this 'UnstowFile' from your bootstrapper"
    }
}
