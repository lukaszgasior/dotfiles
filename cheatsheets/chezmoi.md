# chezmoi

## Basic commands

```powershell
chezmoi apply          # apply changes from source to the system
chezmoi diff           # preview what would change
chezmoi status         # list changed files
chezmoi update         # git pull + apply
chezmoi cd             # navigate to source directory (~/.local/share/chezmoi)
```

## Managing files

```powershell
chezmoi edit ~/.bashrc              # edit a file through chezmoi
chezmoi add ~/.bashrc               # add a file to chezmoi
chezmoi forget ~/.bashrc            # remove a file from chezmoi (does not delete from system)
chezmoi re-add                      # update source from current system files
```

## Scripts

Scripts in `.chezmoiscripts/` are run automatically during `chezmoi apply`:

| Prefix | Behavior |
|---|---|
| `run_once_` | runs only once (hash stored in state) |
| `run_onchange_` | runs when script content changes |
| `run_` / `run_after_` | runs on every `chezmoi apply` |
| `run_before_` | runs before files are copied |

### Reset script execution state

```powershell
# reset ALL scripts (run_once and run_onchange)
chezmoi state delete-bucket --bucket scriptState
chezmoi apply

# inspect state (which scripts have been executed)
chezmoi state dump
```

## Data and templates

```powershell
chezmoi data                        # show all variables available in templates
chezmoi execute-template            # test a template (stdin)
chezmoi execute-template '{{ .chezmoi.os }}'
```

Files with `.tmpl` extension are templates — they have access to data from `.chezmoidata/` and `chezmoi.toml`.

## Env vars available in scripts

| Variable | Value |
|---|---|
| `CHEZMOI_SOURCE_DIR` | path to the source directory |
| `CHEZMOI_SOURCE_PATH` | path to the current script in source |

## Debugging

```powershell
chezmoi apply --verbose             # verbose output
chezmoi apply --dry-run             # simulate without applying changes
chezmoi verify                      # check if files are in sync
```
