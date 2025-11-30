#!/bin/bash
# Script to make Mullvad randomly reconnect to new servers at a random time up to 12hrs.
# Albania al, Australia au, Austria at
# Belgium be, Brazil br, Bulgaria bg
# Canada ca, Chile cl, Colombia co
# Czechia cz, Denmark dk, Estonia ee
# Finland fi, France fr, Germany de
# Hong Kong hk, Italy it, Japan jp
# Mexico mx, Netherlands nl, Norway no
# Peru pe, Poland pl, Romania ro
# Singapore sg, Spain es, Sweden se
# Switzerland ch, United Kingdom gb, United States us
# Argentina ar

LOCATIONS=(
  "al" "au" "at"
  "be" "br" "bg"
  "ca" "cl" "co"
  "cz" "dk" "ee"
  "fi" "fr" "de"
  "hk" "it" "jp"
  "mx" "nl" "no"
  "pe" "pl" "ro"
  "sg" "es" "se"
  "ch" "gb" "us"
  "ar"
)

RANDLOC=${LOCATIONS[$RANDOM % ${#LOCATIONS[@]}]}

RANDNUM=$(shuf -i 1-43200 -n 1)
sleep $((RANDNUM))s

mullvad relay set tunnel wireguard entry location us
mullvad relay set location $RANDLOC
mullvad reconnect
