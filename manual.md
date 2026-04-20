# dev-env-setup — Manual

## NAME

setup.sh — interactive developer environment setup tool for Ubuntu Linux

## SYNOPSIS

```
sudo bash setup.sh
```

## DESCRIPTION

Installs a curated set of developer tools on Ubuntu Linux. The script
presents an interactive menu, detects the host OS, and for each package:
checks if already installed, prompts for confirmation, then installs via
`apt` or falls back to a direct `.deb` / `.tar.gz` download.

## USAGE

1. Run the script as root:

```bash
sudo bash setup.sh
```

2. Select your OS when prompted:

```
1) Linux
2) Windows
```

3. For each package, confirm installation:

```
Package vim is not installed. Do you want to install it? (y/n)
```

Type `y` to install or `n` to skip.

## SUPPORTED PACKAGES

| Package           | Binary              | Method                    |
|-------------------|---------------------|---------------------------|
| git               | `git`               | apt                       |
| gitk              | `gitk`              | apt                       |
| vim               | `vim`               | apt                       |
| sublime-text      | `subl`              | `.deb` direct download    |
| brave             | `brave-browser`     | `.deb` direct download    |
| chrome            | `google-chrome`     | `.deb` direct download    |
| intellij-toolbox  | `jetbrains-toolbox` | `.tar.gz` direct download |
| code (VS Code)    | `code`              | `.deb` direct download    |
| Postman           | `Postman`           | `.tar.gz` direct download |
| mongodb           | `mongod`            | `.deb` direct download    |

## EXAMPLES

Install all packages interactively:

```bash
sudo bash setup.sh
# Select: 1 (Linux)
# Answer y/n for each package
```

Run from any directory (paths resolve automatically):

```bash
sudo bash /path/to/dev-env-setup/setup.sh
```

## ADDING A NEW PACKAGE

1. Add the name to the `packages` array in `linux-script.sh`
2. If the binary name differs, add to `bin_names`
3. If not in apt, add a `"deb|<url>"` or `"tar|<url>"` entry to `package_sources`
4. For tar downloads, optionally add a SHA-256 checksum to `package_checksums`

## REQUIREMENTS

- Ubuntu Linux (20.04+)
- Root access
- `wget`
- `bash` 4.0+ (associative arrays)

## FILES

| File               | Purpose                                      |
|--------------------|----------------------------------------------|
| `setup.sh`         | Entry point — OS detection, menu, dispatch   |
| `linux-script.sh`  | Package config + install logic               |
| `windows-script.sh`| Placeholder (not yet implemented)            |
| `manual.md`        | This manual                                  |
| `README.md`        | Project documentation                        |

## SEE ALSO

README.md
