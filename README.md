dotfiles for windows

- Windows Terminal (portable)
- vscode
- git config
- miscellaneous PS scripts

## WSL2
```
cd
git clone
cd dotfiles
bash install.sh
source ~/.bashrc
```

## Docker/Podman image

* to build custom image, run this command from root folder of this repo:
`podman build -t mycustomeimage -f .\docker\Dockerfile .`

* to run custom image run:
`podman run -it --hostname=work --name=work -v shared:/projects mycustomeimage`
