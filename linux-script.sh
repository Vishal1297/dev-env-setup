#!/bin/bash

# Setup the environment
#
# This script is used to setup the environment for the rest of the
# scripts.
#
# This script is called by the main script.

# Packages to install
# This is a list of packages to install.

# Note: chromium is excluded — on modern Ubuntu it is snap-only and has no
# stable .deb download URL. Use 'snap install chromium' separately if needed.
packages=(git gitk vim sublime-text brave chrome intellij-toolbox code Postman mongodb)

# Map package names to their actual binary names on PATH.
# Packages without a standard binary will fall back to dpkg-query.
declare -A bin_names=(
    [sublime-text]="subl"
    [brave]="brave-browser"
    [chrome]="google-chrome"
    [intellij-toolbox]="jetbrains-toolbox"
    [Postman]="Postman"
    [mongodb]="mongod"
)

# Map package names to direct download URLs for manual installation.
# Format: "type|url" where type is "deb" or "tar".
# Update these URLs as new versions are released.
declare -A package_sources=(
    [sublime-text]="deb|https://download.sublimetext.com/sublime-text_build-4169_amd64.deb"
    [brave]="deb|https://brave-browser-apt-release.s3.brave.com/brave-browser_amd64.deb"
    [chrome]="deb|https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    [intellij-toolbox]="tar|https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.1.3.18901.tar.gz"
    [Postman]="tar|https://dl.pstmn.io/download/latest/linux_64"
    [code]="deb|https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    [mongodb]="deb|https://repo.mongodb.org/apt/ubuntu/dists/jammy/mongodb-org/7.0/multiverse/binary-amd64/mongodb-org-server_7.0.20_amd64.deb"
)

# Map package names to expected sha256 checksums for tar downloads.
# Leave empty to skip verification (not recommended for production).
declare -A package_checksums=(
    [intellij-toolbox]=""
    [Postman]=""
)

DOWNLOAD_DIR="$(mktemp -d /tmp/dev-env-setup.XXXXXXXXXX)"

# Check if a package is installed by looking for its binary or querying dpkg.
is_installed() {
    local pkg="$1"
    local bin="${bin_names[$pkg]:-$pkg}"

    if [ -n "$bin" ] && command -v "$bin" &>/dev/null; then
        return 0
    fi

    # Fallback: check if the apt package is installed via dpkg
    if dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed"; then
        return 0
    fi

    return 1
}

# Install a .deb file: download, install via dpkg, fix dependencies.
install_deb() {
    local pkg="$1"
    local url="$2"
    local deb_file="${DOWNLOAD_DIR}/${pkg}.deb"

    echo "Downloading $pkg from $url..."
    if ! wget -q --show-progress -O "$deb_file" "$url"; then
        echo "Error: Failed to download $pkg."
        return 1
    fi

    echo "Installing $pkg via dpkg..."
    if ! dpkg -i "$deb_file"; then
        echo "Fixing missing dependencies for $pkg..."
        apt-get install -f -y
    fi

    rm -f "$deb_file"

    if is_installed "$pkg"; then
        echo "$pkg installed successfully."
    else
        echo "Warning: $pkg may not have installed correctly."
        return 1
    fi
}

# Install a tar.gz archive: download, verify checksum, extract to /opt,
# symlink binary to /usr/local/bin, create .desktop shortcut if applicable.
install_tar() {
    local pkg="$1"
    local url="$2"
    local tar_file="${DOWNLOAD_DIR}/${pkg}.tar.gz"
    local install_dir="/opt/${pkg}"
    local expected_checksum="${package_checksums[$pkg]}"

    echo "Downloading $pkg from $url..."
    if ! wget -q --show-progress -O "$tar_file" "$url"; then
        echo "Error: Failed to download $pkg."
        return 1
    fi

    # Verify checksum if one is provided
    if [ -n "$expected_checksum" ]; then
        local actual_checksum
        actual_checksum=$(sha256sum "$tar_file" | awk '{print $1}')
        if [ "$actual_checksum" != "$expected_checksum" ]; then
            echo "Error: Checksum mismatch for $pkg."
            echo "  Expected: $expected_checksum"
            echo "  Got:      $actual_checksum"
            rm -f "$tar_file"
            return 1
        fi
        echo "Checksum verified for $pkg."
    else
        echo "Warning: No checksum configured for $pkg, skipping verification."
    fi

    # Extract to /opt/<package-name>
    echo "Extracting $pkg to $install_dir..."
    mkdir -p "$install_dir"
    if ! tar -xzf "$tar_file" -C "$install_dir" --strip-components=1; then
        echo "Error: Failed to extract $pkg."
        rm -f "$tar_file"
        return 1
    fi

    rm -f "$tar_file"

    # Symlink the binary to /usr/local/bin if a known binary name exists
    local bin="${bin_names[$pkg]}"
    local symlink_created=false
    if [ -n "$bin" ]; then
        local bin_path
        bin_path=$(find "$install_dir" -maxdepth 2 -name "$bin" -type f | head -1)
        if [ -n "$bin_path" ]; then
            ln -sf "$bin_path" "/usr/local/bin/${bin}"
            echo "Symlinked $bin to /usr/local/bin/${bin}."
            symlink_created=true
        fi
    fi

    # Create a .desktop file for GUI applications only if symlink was created
    if [ "$symlink_created" = true ]; then
        local desktop_file="/usr/share/applications/${pkg}.desktop"
        local bin_for_exec="${bin_names[$pkg]:-$pkg}"
        # Try to find an icon in the install directory
        local icon_path
        icon_path=$(find "$install_dir" -maxdepth 3 \( -name "*.png" -o -name "*.svg" \) -type f | head -1)
        icon_path="${icon_path:-${install_dir}/${pkg}.png}"

        echo "Creating desktop shortcut for $pkg..."
        tee "$desktop_file" > /dev/null <<EOF
[Desktop Entry]
Type=Application
Name=$pkg
Exec=/usr/local/bin/${bin_for_exec}
Icon=${icon_path}
Terminal=false
Categories=Development;
EOF
        chmod 644 "$desktop_file"
    fi

    if is_installed "$pkg"; then
        echo "$pkg installed successfully."
    else
        echo "Warning: $pkg extracted to $install_dir but binary may not be on PATH."
        # Clean up broken install artifacts
        local bin_cleanup="${bin_names[$pkg]}"
        if [ -n "$bin_cleanup" ]; then
            rm -f "/usr/local/bin/${bin_cleanup}"
        fi
        rm -f "/usr/share/applications/${pkg}.desktop"
    fi
}

# Install a package from its configured source URL.
install_from_source() {
    local pkg="$1"
    local source_entry="${package_sources[$pkg]}"

    if [ -z "$source_entry" ]; then
        echo "Error: No download source configured for $pkg."
        echo "Add an entry to the package_sources map in this script."
        return 1
    fi

    local type="${source_entry%%|*}"
    local url="${source_entry#*|}"

    case "$type" in
        deb)
            install_deb "$pkg" "$url"
            ;;
        tar)
            install_tar "$pkg" "$url"
            ;;
        *)
            echo "Error: Unknown source type '$type' for $pkg."
            return 1
            ;;
    esac
}

echo "Updating package lists..."
apt-get update -y

echo "Installing packages..."

# The script will install these packages.
# The script will also install the packages that are required by the packages in this list.

for name in "${packages[@]}"; do
    echo "Installing $name..."
    if ! is_installed "$name"; then
        echo "Package $name is not installed. Do you want to install it? (y/n)"
        read -r answer
        if [ "$answer" == "y" ]; then
            if [ -n "${package_sources[$name]}" ]; then
                # Package has a known direct-download source — use it to
                # avoid installing the wrong apt package (e.g. an old
                # transitional 'mongodb' instead of mongodb-org-server 7.0).
                install_from_source "$name"
            elif apt-cache show "$name" &>/dev/null; then
                if ! apt-get install -y "$name"; then
                    echo "apt-get install failed for $name. Attempting manual install..."
                    install_from_source "$name"
                fi
            else
                echo "Package $name not found in apt and no manual source configured."
            fi
        else
            echo "Skipping $name."
        fi
    else
        echo "Package $name is already installed."
    fi
done

# Clean up download directory
if [ -d "$DOWNLOAD_DIR" ]; then
    rm -rf "$DOWNLOAD_DIR"
fi