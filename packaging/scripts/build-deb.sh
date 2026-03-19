#!/bin/bash
set -euo pipefail

# Build lfetch locally and create a Debian package in a single artifact folder

VERSION="${1:-0.1.0}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
PACKAGING_DIR="$PROJECT_ROOT/packaging"
ARCH="$(dpkg --print-architecture)"
OUT_DIR="$PACKAGING_DIR/dist/deb"
ARTIFACT_DIR="$OUT_DIR/lfetch_${VERSION}_${ARCH}"
PKG_ROOT="$ARTIFACT_DIR/root"
DEB_FILE="$ARTIFACT_DIR/lfetch_${VERSION}_${ARCH}.deb"

echo "Building lfetch..."
(cd "$PROJECT_ROOT" && lake build lfetch)

echo "Creating Debian package (version $VERSION, arch $ARCH)..."
echo "Artifact directory: $ARTIFACT_DIR"

# Create package structure in one build folder
rm -rf "$ARTIFACT_DIR"
mkdir -p "$PKG_ROOT/DEBIAN"
mkdir -p "$PKG_ROOT/usr/bin"
mkdir -p "$PKG_ROOT/usr/share/lfetch"

# Install binary
install -m 0755 "$PROJECT_ROOT/.lake/build/bin/lfetch" "$PKG_ROOT/usr/bin/lfetch"

# Install default config
install -m 0644 "$PACKAGING_DIR/etc/config.json.default" "$PKG_ROOT/usr/share/lfetch/config.json.default"

# Generate control file from template and override version/architecture
awk -v version="$VERSION" -v arch="$ARCH" '
	BEGIN { hasVersion = 0; hasArch = 0 }
	/^Version:/ { print "Version: " version; hasVersion = 1; next }
	/^Architecture:/ { print "Architecture: " arch; hasArch = 1; next }
	{ print }
	END {
		if (!hasVersion) print "Version: " version
		if (!hasArch) print "Architecture: " arch
	}
' "$PACKAGING_DIR/debian/control" > "$PKG_ROOT/DEBIAN/control"

# Install postinst script
install -m 0755 "$PACKAGING_DIR/debian/postinst" "$PKG_ROOT/DEBIAN/postinst"

# Build .deb
dpkg-deb --build --root-owner-group "$PKG_ROOT" "$DEB_FILE"

echo "✓ Created $DEB_FILE"
echo ""
echo "To install:"
echo "  sudo dpkg -i $DEB_FILE"
echo ""
echo "To test without install:"
echo "  dpkg -c $DEB_FILE"
echo ""
echo "Package tree root:"
echo "  $PKG_ROOT"
