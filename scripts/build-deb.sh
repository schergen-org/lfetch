#!/bin/bash
set -euo pipefail

# Build lfetch locally and create a Debian package

VERSION="${1:-0.1.0}"
ARCH="$(dpkg --print-architecture)"

echo "Building lfetch..."
lake build lfetch

echo "Creating Debian package (version $VERSION, arch $ARCH)..."

# Create package structure
PKG_ROOT="pkgroot"
rm -rf "$PKG_ROOT"
mkdir -p "$PKG_ROOT/DEBIAN"
mkdir -p "$PKG_ROOT/usr/bin"
mkdir -p "$PKG_ROOT/usr/share/lfetch"

# Install binary
install -m 0755 .lake/build/bin/lfetch "$PKG_ROOT/usr/bin/lfetch"

# Install default config
install -m 0644 etc/config.json.default "$PKG_ROOT/usr/share/lfetch/config.json.default"

# Generate control file
cat > "$PKG_ROOT/DEBIAN/control" <<EOF
Package: lfetch
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: schergen-org <noreply@github.com>
Depends: coreutils
Description: Simple system information tool written in Lean 4
 lfetch prints concise system information in a neofetch-style layout.
 Configure via ~/.config/lfetch/config.json
EOF

# Install postinst script
install -m 0755 debian/postinst "$PKG_ROOT/DEBIAN/postinst"

# Build .deb
DEB_FILE="lfetch_${VERSION}_${ARCH}.deb"
dpkg-deb --build --root-owner-group "$PKG_ROOT" "$DEB_FILE"

echo "✓ Created $DEB_FILE"
echo ""
echo "To install:"
echo "  sudo dpkg -i $DEB_FILE"
echo ""
echo "To test without install:"
echo "  dpkg -c $DEB_FILE"
