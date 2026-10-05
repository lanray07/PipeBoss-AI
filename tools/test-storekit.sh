#!/usr/bin/env bash
set -euo pipefail
derived_data="$1"
output="$2"
mkdir -p "$output"
devices="$(python3 tools/select-simulators.py)"
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
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance 120 \
    -maximum-test-execution-time-allowance 180 \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGN_IDENTITY=- \
    test | tee "$output/$kind.log"
  xcrun simctl shutdown "$udid" || true
done <<< "$devices"
