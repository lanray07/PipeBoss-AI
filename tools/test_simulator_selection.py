import importlib.util
from pathlib import Path
import unittest

spec = importlib.util.spec_from_file_location("select_simulators", Path(__file__).with_name("select-simulators.py"))
selector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(selector)


class SimulatorSelectionTests(unittest.TestCase):
    def inventory(self):
        return {
            "runtimes": [
                {"identifier": "com.apple.CoreSimulator.SimRuntime.iOS-26-2", "version": "26.2", "isAvailable": True},
                {"identifier": "com.apple.CoreSimulator.SimRuntime.iOS-26-6", "version": "26.6", "isAvailable": True}
            ],
            "devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-26-2": [
                    {"name": "iPhone 17 Pro Max", "udid": "old", "isAvailable": True}],
                "com.apple.CoreSimulator.SimRuntime.iOS-26-6": [
                    {"name": "iPhone 17 Pro Max", "udid": "phone", "isAvailable": True},
                    {"name": "iPad Pro 13-inch", "udid": "pad", "isAvailable": True}]
            },
            "devicetypes": [
                {"name": "iPhone 14 Pro Max", "identifier": "phone14-type"},
                {"name": "iPhone 17 Pro Max", "identifier": "phone-type"},
                {"name": "iPad Pro 13-inch", "identifier": "pad-type"}]
        }

    def test_uses_only_pinned_runtime(self):
        selected = selector.selected_devices(self.inventory(), "26.6")
        self.assertEqual([d[1] for d in selected], ["phone", "pad"])

    def test_missing_runtime_does_not_fall_back(self):
        with self.assertRaises(ValueError):
            selector.selected_devices(self.inventory(), "26.7")

    def test_creation_prefers_current_screenshot_device(self):
        inventory = self.inventory()
        inventory["devices"]["com.apple.CoreSimulator.SimRuntime.iOS-26-6"] = []
        selected = selector.selected_devices(inventory, "26.6")
        self.assertTrue(all(d[1] is None for d in selected))
        self.assertEqual([d[2] for d in selected], ["phone-type", "pad-type"])

    def test_unavailable_runtime_is_rejected(self):
        inventory = self.inventory()
        inventory["runtimes"][1]["isAvailable"] = False
        with self.assertRaises(ValueError):
            selector.selected_devices(inventory, "26.6")


if __name__ == "__main__":
    unittest.main()
