#!/usr/bin/env python3
"""Select or create iPhone/iPad simulators on the explicitly tested runtime."""
import json
import os
import subprocess


def selected_devices(inventory, version):
    runtimes = [r for r in inventory["runtimes"]
                if r.get("isAvailable") and r["version"] == version
                and r["identifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-")]
    if not runtimes:
        raise ValueError(f"Required iOS {version} Simulator runtime is not installed")
    runtime_id = runtimes[0]["identifier"]
    existing = inventory["devices"].get(runtime_id, [])
    result = []
    for kind, preferred in [("iPhone", "Pro Max"), ("iPad", "13-inch")]:
        def priority(device):
            name = device["name"]
            return (0 if name == "iPhone 17 Pro Max" else 1 if preferred in name else 2, name)

        candidates = [d for d in existing if d.get("isAvailable") and d["name"].startswith(kind)]
        candidates.sort(key=priority)
        types = [d for d in inventory["devicetypes"] if d["name"].startswith(kind)]
        types.sort(key=priority)
        if not candidates and not types:
            raise ValueError(f"No {kind} device type is installed")
        result.append((kind, candidates[0]["udid"] if candidates else None,
                       types[0]["identifier"] if types else None, runtime_id))
    return result


def main():
    version = os.environ.get("PIPEBOSS_SIMULATOR_RUNTIME", "26.1")
    inventory = json.loads(subprocess.check_output(["xcrun", "simctl", "list", "-j"]))
    for kind, udid, device_type, runtime in selected_devices(inventory, version):
        if udid is None:
            udid = subprocess.check_output(
                ["xcrun", "simctl", "create", f"{kind} PipeBoss", device_type, runtime],
                text=True).strip()
        print(kind, udid)


if __name__ == "__main__":
    main()
