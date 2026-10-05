#!/usr/bin/env bash
set -euo pipefail
derived_data="$1"
output="$2"
mkdir -p "$output"
devices="$(xcrun simctl list devices available -j | python3 -c '
import json,sys
devices=[d for values in json.load(sys.stdin)["devices"].values() for d in values]
for kind in ["iPhone", "iPad"]:
    matches=[d for d in devices if d["name"].startswith(kind)]
    if not matches: raise SystemExit("No available " + kind + " simulator")
    preferred=[d for d in matches if ("Pro Max" if kind=="iPhone" else "13-inch") in d["name"]]
    print(kind + " " + (preferred or matches)[0]["udid"])
')"
while read -r kind udid; do
  xcodebuild \
    -project PipeBossAI.xcodeproj \
    -scheme PipeBossAI \
    -configuration Debug \
    -derivedDataPath "$derived_data" \
    -destination "platform=iOS Simulator,id=$udid" \
    -resultBundlePath "$output/$kind.xcresult" \
    -parallel-testing-enabled NO \
    -maximum-concurrent-test-simulator-destinations 1 \
    CODE_SIGNING_ALLOWED=NO \
    test | tee "$output/$kind.log"
  xcrun simctl shutdown "$udid" || true
done <<< "$devices"
