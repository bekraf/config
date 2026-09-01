# Bron van de VLC Winamp-skin

## Mappen

- `classic-winamp-1x/` — de bewerkte 1x-bron op ware Winamp-grootte (275x116).
  Bestandsnamen in kleine letters (VLC zoekt hoofdlettergevoelig naar
  `main.bmp`), bitmaps 24-bits ongecomprimeerd (VLC 3.0.23 crasht op palet-BMP's
  in combinatie met ffmpeg 8.x), `FreeSansBold.ttf` meegeleverd, en een eigen
  `theme.xml` waarin equalizer en playlist op `visible="false"` staan.
Alles daarna is afgeleid: `build.sh` herkleurt en schaalt in een tijdelijke map
en levert alleen het `.wsz` af. Er staat dus bewust geen gegenereerde kopie in
de repo — `classic-winamp-1x/` is de enige bron die je met de hand bewerkt.

## Palet

| Rol          | Hex       | Waar zichtbaar                                  |
|--------------|-----------|-------------------------------------------------|
| Dark Orange  | `#391807` | achtergrond, schaduw, displayvlak                |
| Light Orange | `#89380f` | chassis, knopvlakken, middentonen                |
| Text         | `#ffe4a7` | opschriften, iconen, highlights, spectrumtop     |
| Hover        | `#234990` | ingedrukte knoppen, playlistselectie, piekstipje |

## Bouwen

    cd ~/.config/vlc/skins2-src
    ./build.sh              # palet, 3x  -> riced-winamp-3x.wsz
    ./build.sh 4            # palet, 4x
    ./build.sh 3 classic    # originele kleuren, 3x

`build.sh` herkleurt, schaalt en zet het `.wsz` in
`~/.local/share/vlc/skins2/`. Boven ongeveer 5x worden de pixelblokken erg grof.

De losse stappen (`recolor_skin.py`, `scale_skin.py`) zijn ook apart bruikbaar;
beide nemen een bron- en een doelmap.

Andere kleuren: pas de vier constanten boven in `recolor_skin.py` aan. De
verdeling zit in `RAMP_NORMAL` / `RAMP_PRESSED` — het middelste stoppunt (`0.55`)
bepaalt hoe licht of donker de skin in het geheel uitvalt.

## Na het bouwen

In `~/.config/vlc/vlcrc`:

- `skins2-last` naar het nieuwe `.wsz` laten wijzen;
- `skins2-config=` leegmaken — die onthoudt de oude venstergrootte en overschrijft
  anders de nieuwe.

VLC herschrijft `vlcrc` bij het afsluiten, dus pas het bestand aan terwijl VLC
niet draait.

## Hyprland

De tegelregel staat in `~/.config/hypr/hyprland.conf`:

    windowrule = tile on, match:class ^(Vlc)$

Let op: sinds Hyprland 0.53 hebben matchers een `match:`-prefix en booleaanse
effecten een expliciete waarde. De oude vorm `windowrule = tile, class:^(Vlc)$`
geeft alleen `invalid field`.
