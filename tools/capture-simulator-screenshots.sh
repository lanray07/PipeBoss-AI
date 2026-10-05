#!/usr/bin/env bash
set -euo pipefail
app_path="$1"
output="$2"
mapfile_compatible_devices="$(python3 tools/select-simulators.py)"
while read -r kind udid; do
  xcrun simctl boot "$udid" || true
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl status_bar "$udid" override --time '9:41' --batteryState charged --batteryLevel 100
  xcrun simctl ui "$udid" appearance light
  xcrun simctl install "$udid" "$app_path"
  mkdir -p "$output/$kind"
  # Let first-boot system notifications disappear before capturing the app.
  xcrun simctl launch "$udid" com.pipebossai.app --capture-screen dashboard
  sleep 20
  for screen in dashboard diagnosis result skills tools learning; do
    xcrun simctl terminate "$udid" com.pipebossai.app || true
    xcrun simctl launch "$udid" com.pipebossai.app --capture-screen "$screen"
    sleep 4
    xcrun simctl io "$udid" screenshot "$output/$kind/$screen.png"
  done
  xcrun simctl shutdown "$udid"
done <<< "$mapfile_compatible_devices"
swift tools/validate-screenshots.swift "$output"
