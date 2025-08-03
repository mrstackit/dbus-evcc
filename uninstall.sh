#!/bin/bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SERVICE_NAME=$(basename "$SCRIPT_DIR")

# Entferne Service-Link (OpenRC/VenusOS)
if [ -L "/service/$SERVICE_NAME" ]; then
    echo "Entferne /service/$SERVICE_NAME"
    rm "/service/$SERVICE_NAME"
fi

# Beende supervisord-Dienst (nur falls aktiv)
PID=$(pgrep -f "supervise.*/$SERVICE_NAME" || true)
if [ -n "$PID" ]; then
    echo "Beende laufenden Service $SERVICE_NAME (PID: $PID)"
    kill "$PID"
fi

# Entferne Ausführbarkeit von Service-Datei (falls vorhanden)
if [ -f "$SCRIPT_DIR/service/run" ]; then
    chmod a-x "$SCRIPT_DIR/service/run"
fi

# Entferne rc.local-Eintrag
RCFILE="/data/rc.local"
if [ -f "$RCFILE" ]; then
    grep -v "$SERVICE_NAME" "$RCFILE" > "${RCFILE}.tmp" && mv "${RCFILE}.tmp" "$RCFILE"
    chmod +x "$RCFILE"
    echo "rc.local-Eintrag entfernt (sofern vorhanden)."
fi

# Installationsverzeichnis entfernen
if [ -d "$SCRIPT_DIR" ]; then
    echo "Entferne Installationsverzeichnis: $SCRIPT_DIR"
    rm -rf "$SCRIPT_DIR"
fi

echo "Deinstallation abgeschlossen."
