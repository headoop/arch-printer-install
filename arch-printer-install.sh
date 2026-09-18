#!/usr/bin/env bash

set -euo pipefail

# use sudo /usr/sbin/lpinfo -v to see list of devices
# device
device="lpd://BRW541379A0F2DF/BINARY_P1"
# search for ppd and model:
# lpinfo --make-and-model "Brother DCP-J774DW" -l -m
# ppd
#p=/usr/share/ppd/Brother/brother_dcpj774dw_printer_en.ppd
# model
model="Brother/brother_dcpj774dw_printer_en.ppd"
# location
location="Wohnzimmer"
# default destination, restored at the end
default_queue="GraustufenNormalDuplex"

## Brother DCPJ774DW
#
# ❯ lpoptions -l
# PageSize/Media Size: *A4 BrA4_B Letter BrLetter_B Legal Executive A5 A6 BrA6_B B5 B6 BrPostC4x6_S BrPostC4x6_B BrIndexC5x8_S BrIndexC5x8_B BrPhotoL_S BrPhotoL_B BrPhoto2L_S BrPhoto2L_B Postcard BrHagaki_B DoublePostcardRotated EnvDL EnvC5 Env10 EnvMonarch EnvYou4 EnvChou3 EnvChou4 195x270mm EnvYou2
# Duplex/Two-Sided: DuplexTumble *DuplexNoTumble None
# BRResolution/Print Quality: PlainFast *PlainNormal Fast Normal High Best
# BRMonoColor/Color / Grayscale: Color *Mono
# BRSlowDrying/Slow Drying Paper: *OFF ON
# BRMediaType/Media Type: *PlainDuplex Plain Inkjet BrotherGlossyR BrotherBP60Matte Glossy InkjetHagakiAtena InkjetHagakiUra GlossyHagakiUra GlossyHagakiAtena PlainHagakiUra PlainHagakiAtena GlossyVolumeUp
# BRColorPaperThick/Paper Thickness: *Regular Thick Env
# BRBiDir/Bi-Directional Printing: OFF *ON
# BRColorMatching/Color Mode: *Natural Vivid None
# BRJpeg/Change Data Transfer Mode: *Recommended QualityPrior SpeedPrior
# BRHalfTonePattern/Halftone Pattern: *Diffusion Dither
# BRColorEnhancement/Color Enhancement: *OFF ON
# BRBrightness/Brightness: -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 *0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
# BRContrast/Contrast: -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 *0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
# BRRed/Red: -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 *0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
# BRGreen/Green: -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 *0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
# BRBlue/Blue: -20 -19 -18 -17 -16 -15 -14 -13 -12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 *0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
# BRReduceSmudgeDx/Duplex Printing: *OFF LOW HIGH
# BRReduceSmudgeSx/Simplex Printing: *OFF LOW HIGH

# options every queue gets
common_options=(
  -o PageSize=A4
  -o printer-is-shared=true
  # a sleeping Wi-Fi printer must not disable the queue
  -o printer-error-policy=retry-job
)

# create_queue <name> [further lpadmin options ...]
create_queue() {
  local name="$1"
  shift

  # only delete what exists, so a real failure still surfaces
  if lpstat -p "$name" >/dev/null 2>&1; then
    lpadmin -x "$name"
  fi

  lpadmin -p "$name" -v "$device" -m "$model" -L "$location" \
    "${common_options[@]}" "$@" \
    -D "$name" -E
}

# ┌────────────────────────┬────────────────┬─────────────┬─────────────┬──────────────┬──────────────────────┐
# │ Queue                  │ Duplex         │ BRMonoColor │ BRMediaType │ BRResolution │ Extras               │
# ├────────────────────────┼────────────────┼─────────────┼─────────────┼──────────────┼──────────────────────┤
# │ Draft                  │ DuplexNoTumble │ Mono        │ PlainDuplex │ PlainFast    │ Smudge OFF (speed)   │
# │ GraustufenNormalDuplex │ DuplexNoTumble │ Mono        │ PlainDuplex │ PlainNormal  │ Smudge LOW           │
# │ FarbeNormalDuplex      │ DuplexNoTumble │ Color       │ PlainDuplex │ PlainNormal  │ Smudge LOW           │
# │ FotoBestGlossy         │ None           │ Color       │ Glossy      │ Best         │ Vivid, Thick, UniDir │
# └────────────────────────┴────────────────┴─────────────┴─────────────┴──────────────┴──────────────────────┘
#
# identical for every queue: see common_options

create_queue Draft \
  -o Duplex=DuplexNoTumble \
  -o BRMonoColor=Mono \
  -o BRMediaType=PlainDuplex \
  -o BRResolution=PlainFast \
  -o BRReduceSmudgeDx=OFF

create_queue GraustufenNormalDuplex \
  -o Duplex=DuplexNoTumble \
  -o BRMonoColor=Mono \
  -o BRMediaType=PlainDuplex \
  -o BRResolution=PlainNormal \
  -o BRReduceSmudgeDx=LOW

create_queue FarbeNormalDuplex \
  -o Duplex=DuplexNoTumble \
  -o BRMonoColor=Color \
  -o BRMediaType=PlainDuplex \
  -o BRResolution=PlainNormal \
  -o BRReduceSmudgeDx=LOW

create_queue FotoBestGlossy \
  -o Duplex=None \
  -o BRMonoColor=Color \
  -o BRMediaType=Glossy \
  -o BRResolution=Best \
  -o BRColorPaperThick=Thick \
  -o BRColorMatching=Vivid \
  -o BRColorEnhancement=ON \
  -o BRJpeg=QualityPrior \
  -o BRBiDir=OFF

# lpadmin -x drops the default destination too, so set it again
lpadmin -d "$default_queue"
