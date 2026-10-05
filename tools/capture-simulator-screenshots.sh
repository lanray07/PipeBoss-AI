#!/usr/bin/env bash
set -euo pipefail
app_path="$1"
output="$2"
devices_json="$(xcrun simctl list devices available -j)"
mapfile_compatible_devices="$(printf '%s' "$devices_json" | python3 -c '
import json,sys
devices=[d for values in json.load(sys.stdin)["devices"].values() for d in values]
for kind in ["iPhone", "iPad"]:
    candidates=[d for d in devices if d["name"].startswith(kind)]
    if not candidates: raise SystemExit("No available " + kind + " simulator")
    preferred=[d for d in candidates if ("Pro Max" if kind=="iPhone" else "13-inch") in d["name"]]
    device=(preferred or candidates)[0]
    print(kind + " " + device["udid"])
')"
while read -r kind udid; do
  xcrun simctl boot "$udid" || true
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl status_bar "$udid" override --time '9:41' --batteryState charged --batteryLevel 100
  xcrun simctl ui "$udid" appearance light
  xcrun simctl install "$udid" "$app_path"
  mkdir -p "$output/$kind"
  for screen in dashboard diagnosis result skills tools learning; do
    xcrun simctl terminate "$udid" com.pipebossai.app || true
    xcrun simctl launch "$udid" com.pipebossai.app --capture-screen "$screen"
    sleep 4
    xcrun simctl io "$udid" screenshot "$output/$kind/$screen.png"
  done
  xcrun simctl shutdown "$udid"
done <<< "$mapfile_compatible_devices"
