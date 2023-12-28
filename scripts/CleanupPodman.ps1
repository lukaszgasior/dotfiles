# based on https://github.com/containers/podman/issues/17395

wsl --unregister podman-net-usermode
wsl --unregister podman-machine-default

Remove-Item -Path "$env:USERPROFILE\.local\share\containers\podman\machine\wsl" -Recurse -Force
Remove-Item -Path "$env:USERPROFILE\.config\containers\podman\machine" -Recurse -Force
Remove-Item -Path "$env:USERPROFILE\AppData\Roaming\containers" -Recurse -Force

Remove-Item -Path "$env:USERPROFILE\.ssh\podman-machine-default.pub" -Recurse -Force