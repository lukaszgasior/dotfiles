# Prevent conflict with built-in aliases
Remove-Alias gc -Force -ErrorAction SilentlyContinue
Remove-Alias gcb -Force -ErrorAction SilentlyContinue
Remove-Alias gcm -Force -ErrorAction SilentlyContinue
Remove-Alias gcs -Force -ErrorAction SilentlyContinue
Remove-Alias gl -Force -ErrorAction SilentlyContinue
Remove-Alias gm -Force -ErrorAction SilentlyContinue
Remove-Alias gp -Force -ErrorAction SilentlyContinue
Remove-Alias gpv -Force -ErrorAction SilentlyContinue

function g { git $args  }
function ga { git add $args }
function gaa { git add --all $args }
function gs { git status $args }
function gc { git commit -m $args }
function gco { git checkout $args }
function gcb { git checkout -b $args }
function gf { git fetch $args }
function gl { git pull $args }
function gp { git push $args }
