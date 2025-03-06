#!/usr/bin/env bash

PREFIX="CH32V"

flashRamArray=("16K_2K" "32K_10K" "64K_20K" "128K_32K" "128K_64K" "256K_64K")

for flashRam in "${flashRamArray[@]}"; do
  IFS="_" read -r flash ram <<<"$flashRam"

  echo "Generating linker script for $flash flash and $ram ram"
  sed -e "s/__FLASH_SIZE__/$flash/g" -e "s/__RAM_SIZE__/$ram/g" template.ld >"${PREFIX}_${flash}_${ram}.ld"
done
