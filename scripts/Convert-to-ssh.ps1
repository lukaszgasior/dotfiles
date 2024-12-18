$httpsUrl = git remote get-url origin

if ($httpsUrl -match "^https://github\.com/(.+)/(.+)\.git$") {
    $owner = $matches[1]
    $repo = $matches[2]

    $sshUrl = "git@github.com:$owner/$repo.git"

    git remote set-url origin $sshUrl

    Write-Host "Remote URL successfully changed from HTTPS to SSH:"
    Write-Host "Old URL: $httpsUrl"
    Write-Host "New URL: $sshUrl"
}
else {
    Write-Host "Current remote URL is not in HTTPS format or is not from GitHub."
    Write-Host "Current URL: $httpsUrl"
}