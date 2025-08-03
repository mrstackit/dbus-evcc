#!/bin/bash

set -e

# === Konfiguration ===
GITHUB_USER="mrstackit"
GITHUB_REPO="dbus-evcc"
INSTALL_DIR="/data/dbus-evcc"
VERSION_FILE="$INSTALL_DIR/version"
API_URL="https://api.github.com/repos/$GITHUB_USER/$GITHUB_REPO/releases/latest"
TMP_DIR="/tmp/dbus-evcc-update"

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

# === Lokale Version ermitteln ===
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

# === Versionsvergleich ===
if [ "$LOCAL_VERSION" = "$TARGET_VERSION" ]; then
  echo "✅ Version $TARGET_VERSION ist bereits installiert."
  exit 0
fi

# === Nutzerbestätigung ===
if [ "$SILENT" = false ]; then
  read -p "Möchtest du auf Version $TARGET_VERSION aktualisieren? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "⏭️  Update abgebrochen."
    exit 0
  fi
else
  echo "🔁 Silent-Modus aktiviert – Update wird automatisch durchgeführt."
fi

# === Update durchführen ===
ZIP_URL="https://github.com/$GITHUB_USER/$GITHUB_REPO/archive/refs/tags/$TARGET_VERSION.zip"

echo "⬇️  Lade Version $TARGET_VERSION..."
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
wget -q -O "$TMP_DIR/update.zip" "$ZIP_URL"
unzip -q "$TMP_DIR/update.zip" -d "$TMP_DIR"

# Backup config.ini
if [ -f "$INSTALL_DIR/config.ini" ]; then
  cp "$INSTALL_DIR/config.ini" /tmp/config.ini.backup
fi

# Stoppe Dienst
if [ -L "/service/dbus-evcc" ]; then
  echo "🛑 Stoppe dbus-evcc..."
  svc -d /service/dbus-evcc
  sleep 1
fi

# Dateien kopieren
cp -r "$TMP_DIR/$GITHUB_REPO-$TARGET_VERSION/"* "$INSTALL_DIR/"

# config.ini wiederherstellen
if [ -f /tmp/config.ini.backup ]; then
  cp /tmp/config.ini.backup "$INSTALL_DIR/config.ini"
  rm /tmp/config.ini.backup
fi

# ✅ Version schreiben
echo "$TARGET_VERSION" > "$VERSION_FILE"

# Dienst starten
if [ -L "/service/dbus-evcc" ]; then
  echo "🚀 Starte dbus-evcc..."
  svc -u /service/dbus-evcc
fi

rm -rf "$TMP_DIR"

echo ""
echo "✅ Update auf Version $TARGET_VERSION erfolgreich abgeschlossen."
