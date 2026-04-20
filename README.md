# dev-env-setup

Interactive shell tool to set up a developer environment on Ubuntu Linux. Select your OS, pick the packages you need, and the script handles installation via `apt` with automatic `.deb` / `.tar.gz` fallback.

## Quick Start

```bash
# Clone the repo
git clone https://github.com/vishal1297/dev-env-setup.git
cd dev-env-setup

# Run as root (required for Linux package installation)
sudo bash setup.sh
```

Follow the on-screen prompts: select your OS, then confirm each package with `y` or `n`.

## Supported Platforms

| Platform | Status |
|----------|--------|
| Linux (Ubuntu) | ✅ Supported |
| Windows | 🚧 Placeholder (not yet implemented) |

## Supported Packages

| Package | Binary | Install Method |
|---------|--------|----------------|
| git | `git` | apt |
| gitk | `gitk` | apt |
| vim | `vim` | apt |
| Sublime Text | `subl` | apt → `.deb` fallback |
| Brave Browser | `brave-browser` | apt → `.deb` fallback |
| Google Chrome | `google-chrome` | apt → `.deb` fallback |
| IntelliJ Toolbox | `jetbrains-toolbox` | apt → `.tar.gz` fallback |
| VS Code | `code` | apt → `.deb` fallback |
| Postman | `Postman` | apt → `.tar.gz` fallback |
| MongoDB | `mongod` | apt → `.deb` fallback |

> **Note:** Chromium is excluded — on modern Ubuntu it is snap-only with no stable `.deb` download. Use `snap install chromium` separately if needed.

## How It Works

```
setup.sh
  ├── Detect OS (uname -s)
  ├── User selects OS (1=Linux, 2=Windows)
  ├── Validate selection matches detected OS
  ├── [Linux] Require root (id -u == 0)
  └── source linux-script.sh
        ├── apt-get update
        └── For each package:
              ├── Already installed? → skip
              ├── Prompt user (y/n)
              ├── Try apt-cache show → apt-get install
              ├── If apt fails → install_from_source
              │     ├── .deb: wget → dpkg -i → apt-get install -f
              │     └── .tar.gz: wget → sha256 verify → extract to /opt
              │           → symlink binary → create .desktop shortcut
              └── Verify installation via command -v / dpkg-query
```

## Project Structure

```
.
├── setup.sh             # Entry point — OS detection, menu, root check, dispatch
├── linux-script.sh      # Package config + install logic (apt / deb / tar)
├── windows-script.sh    # Placeholder — prints "not yet implemented"
└── README.md
```

## Configuration

All package metadata lives in four bash associative arrays at the top of `linux-script.sh`:

| Array | Purpose |
|-------|---------|
| `packages` | Ordered list of packages to install |
| `bin_names` | Maps package name → binary name for `command -v` checks |
| `package_sources` | Maps package name → `"type\|url"` for manual install (`deb` or `tar`) |
| `package_checksums` | Maps package name → expected SHA-256 for tar downloads |

### Adding a New Package

1. Add the name to the `packages` array
2. If the binary name differs from the package name, add an entry to `bin_names`
3. If not available via apt, add a `"deb|<url>"` or `"tar|<url>"` entry to `package_sources`
4. For tar downloads, optionally add a SHA-256 checksum to `package_checksums`

## Requirements

- Ubuntu Linux (tested on 20.04+)
- Root access (`sudo`)
- `wget` (pre-installed on most Ubuntu systems)
- `bash` 4.0+ (required for associative arrays)

## Roadmap

- [x] Linux (Ubuntu) support
- [x] Interactive package selection
- [x] apt install with `.deb` / `.tar.gz` fallback
- [x] Desktop shortcuts for GUI apps
- [x] SHA-256 checksum verification
- [ ] Windows support
- [ ] macOS support
- [ ] Non-interactive / batch mode

## License

See [LICENSE](LICENSE) for details.