#!/usr/bin/env bash
echo
for i in {0..16}; do
  COLORGUM=$(gum style --foreground "$i" "GUM")
  echo "${i}: ${COLORGUM}"
done
echo
