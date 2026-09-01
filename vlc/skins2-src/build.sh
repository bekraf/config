#!/usr/bin/env bash
# Bouwt de Winamp-skin uit de bron in deze map en installeert hem waar VLC
# skins verwacht. Zonder argumenten: het bureaubladpalet op 3x.
#
#   ./build.sh              -> riced-winamp-3x.wsz
#   ./build.sh 4            -> riced-winamp-4x.wsz
#   ./build.sh 3 classic    -> classic-winamp-3x.wsz (originele kleuren)
#
# Zet daarna skins2-last in ~/.config/vlc/vlcrc naar het gebouwde bestand,
# terwijl VLC niet draait.
set -euo pipefail

FACTOR="${1:-3}"
VARIANT="${2:-riced}"

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/vlc/skins2"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

case "$VARIANT" in
    riced)
        python3 "$SRC_DIR/recolor_skin.py" "$SRC_DIR/classic-winamp-1x" "$WORK/1x"
        ;;
    classic)
        cp -r "$SRC_DIR/classic-winamp-1x" "$WORK/1x"
        ;;
    *)
        echo "onbekende variant: $VARIANT (kies 'riced' of 'classic')" >&2
        exit 1
        ;;
esac

python3 "$SRC_DIR/scale_skin.py" "$WORK/1x" "$WORK/scaled" "$FACTOR"

mkdir -p "$DEST_DIR"
OUT="$DEST_DIR/$VARIANT-winamp-${FACTOR}x.wsz"
rm -f "$OUT"
( cd "$WORK/scaled" && zip -q -r -X "$OUT" . -x '.*' )

echo "gebouwd: $OUT"
