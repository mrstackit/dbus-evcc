#!/bin/bash

set -e

# === Konfiguration ===
GITHUB_USER="mrstackit"
GITHUB_REPO="dbus-evcc"
INSTALL_DIR="/data/dbus-evcc"
VERSION_FILE="$INSTALL_DIR/version"
API_URL="https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest"
TMP_DIR="/tmp/dbus-evcc-update"

# === Sicherheitsprüfung: nicht im Installationsverzeichnis ausführen ===
if [ "$PWD" = "$INSTALL_DIR" ]; then
  echo "❌ Fehler: Bitte führe update.sh nicht direkt im Installationsverzeichnis ($INSTALL_DIR) aus!"
  echo "Beispiel: cd /tmp && $INSTALL_DIR/update.sh"
  exit 1
fi

# === Sicherheitsprüfung: keine alten ZIPs oder Ordner im INSTALL_DIR ===
if [ -f "$INSTALL_DIR/update.zip" ] || ls "$INSTALL_DIR"/dbus-evcc-* &>/dev/null; then
  echo "⚠️  Warnung: Alte Update-Dateien im Installationsverzeichnis gefunden:"
  ls "$INSTALL_DIR"/update.zip "$INSTALL_DIR"/dbus-evcc-* 2>/dev/null || true
  echo ""
  echo "Bitte bereinige das Verzeichnis mit:"
  echo "  rm -rf $INSTALL_DIR/update.zip $INSTALL_DIR/dbus-evcc-*"
  exit 1
fi

# === Argumente parsen ===
SILENT=false
TARGET_VERSION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --silent)
      SILENT=true
      shift
      ;;
    --version)
      TARGET_VERSION="$2"
      shift 2
      ;;
    *)
      echo "❌ Unbekannte Option: $1"
      echo "Verwendung: $0 [--version vX.Y] [--silent]"
      exit 1
      ;;
  esac
done

# === Lokale Version lesen ===
if [ -f "$VERSION_FILE" ]; then
  LOCAL_VERSION=$(cat "$VERSION_FILE")
else
  LOCAL_VERSION="none"
fi

# === Zielversion bestimmen ===
if [ -z "$TARGET_VERSION" ]; then
  echo "📡 Prüfe aktuelle Version auf GitHub..."
  TARGET_VERSION=$(wget -qO- "$API_URL" | grep '"tag_name":' | cut -d '"' -f 4)
  if [ -z "$TARGET_VERSION" ]; then
    echo "❌ Fehler beim Abrufen der GitHub-Version."
    exit 1
  fi
  echo "🌐 Neueste Version auf GitHub: $TARGET_VERSION"
fi

echo ""
echo "🔍 Lokale Version     : $LOCAL_VERSION"
echo "🎯 Zielversion        : $TARGET_VERSION"
echo ""

if [ "$LOCAL_VERSION" = "$TARGET_VERSION" ]; then
  echo "✅ Version $TARGET_VERSION ist bereits installiert."
  exit 0
fi

# === Bestätigung nur im interaktiven Modus ===
if [ "$SILENT" = false ]; then
  read -p "Möchtest du auf Version $TARGET_VERSION aktualisieren? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "⏭️  Update abgebrochen."
    exit 0
  fi
else
  echo "🔁 Silent-Modus aktiviert – Update wird ohne Rückfrage durchgeführt."
fi

# === Dienst stoppen & Prozesse beenden ===
echo "🛑 Stoppe laufende dbus-evcc-Instanzen..."
svc -d /service/dbus-evcc 2>/dev/null || true
pkill -f dbus-evcc.py 2>/dev/null || true
sleep 1

# === ZIP herunterladen und entpacken ===
ZIP_URL="https://github.com/$GITHUB_USER/$GITHUB_REPO/archive/refs/tags/$TARGET_VERSION.zip"
echo "⬇️  Lade Version $TARGET_VERSION..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
wget -q -O "$TMP_DIR/update.zip" "$ZIP_URL"
unzip -q "$TMP_DIR/update.zip" -d "$TMP_DIR"

# === Backup config.ini ===
if [ -f "$INSTALL_DIR/config.ini" ]; then
  cp "$INSTALL_DIR/config.ini" /tmp/config.ini.backup
fi

# === Dateien kopieren (robust & ohne Wildcard) ===
UNZIP_SUBDIR=$(find "$TMP_DIR" -maxdepth 1 -type d -name "$GITHUB_REPO-*" | head -n 1)
if [ -z "$UNZIP_SUBDIR" ]; then
  echo "❌ Entpacktes Verzeichnis wurde nicht gefunden!"
  ls -l "$TMP_DIR"
  exit 1
fi

echo "📂 Entpackt nach: $UNZIP_SUBDIR"
ls -1 "$UNZIP_SUBDIR"

echo "📦 Kopiere Dateien nach $INSTALL_DIR..."
cp -a "$UNZIP_SUBDIR/." "$INSTALL_DIR/"

# === config.ini wiederherstellen ===
if [ -f /tmp/config.ini.backup ]; then
  cp /tmp/config.ini.backup "$INSTALL_DIR/config.ini"
  rm /tmp/config.ini.backup
fi

# === Version schreiben ===
echo "$TARGET_VERSION" > "$VERSION_FILE"

# === Dienst starten ===
echo "🚀 Starte dbus-evcc neu..."
svc -u /service/dbus-evcc

# === Cleanup ===
rm -rf "$TMP_DIR"
rm -f "$INSTALL_DIR/update.zip"
rm -rf "$INSTALL_DIR"/dbus-evcc-*

echo "🔧 Setze Ausführbarkeit für Hilfsskripte..."
chmod a+x "$INSTALL_DIR/install.sh" "$INSTALL_DIR/uninstall.sh" "$INSTALL_DIR/restart.sh"

echo ""
echo "✅ Update auf Version $TARGET_VERSION erfolgreich abgeschlossen."
