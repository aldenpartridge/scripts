#!/bin/bash
#Script to make Mullvad randomly reconnect to new servers once per day at a random time.

RANDNUM=$(shuf -i 1-43200 -n 1)
sleep $((RANDNUM))s
mullvad reconnect
