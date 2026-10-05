import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import localize
from validate_metadata import validate_metadata, PATH


class TranslationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.manifest = self.root / "source.json"
        self.catalog = self.root / "Localizable.xcstrings"
        self.patches = [patch.object(localize, "ROOT", self.root), patch.object(localize, "MANIFEST", self.manifest), patch.object(localize, "CATALOG", self.catalog)]
        for item in self.patches:
            item.start()
        localize.write(self.manifest, {"entries": {
            "Level {level}": {"contexts": ["copy.format.level"], "requiresSafetyReview": False},
            "Isolate before repair.": {"contexts": ["jobs.0.safetyWarning"], "requiresSafetyReview": True},
        }})
        localize.sync_catalog()

    def tearDown(self):
        for item in reversed(self.patches):
            item.stop()
        self.tmp.cleanup()

    def draft(self, source="Level {level}", **flags):
        value = {"translation": "Nivel {level}", "sourceHash": localize.signature(source), "reviewed": True, "safetyReviewed": False}
        value.update(flags)
        path = self.root / "draft.json"
        localize.write(path, {"locale": "es", "entries": {source: value}})
        return path

    def test_placeholder_validation(self):
        localize.validate_translation("Save {percent}%", "Ahorra {percent}%")
        with self.assertRaises(ValueError):
            localize.validate_translation("{item} {item}", "{item}")
        with self.assertRaises(ValueError):
            localize.validate_translation("Level {level}", "Nivel {nivel}")

    def test_brand_and_links(self):
        with self.assertRaises(ValueError):
            localize.validate_translation("PipeBoss Pro", "Otro producto")
        with self.assertRaises(ValueError):
            localize.validate_translation("Read https://example.com/privacy", "Lee https://example.com/terms")

    def test_protected_xml_roundtrip(self):
        source = "PipeBoss Pro & <tools> for {price}. https://example.com/legal"
        root = ET.fromstring(localize.protected_xml(source))
        self.assertEqual("".join(root.itertext()), source)
        self.assertEqual([e.text for e in root.findall("keep")], ["PipeBoss Pro", "{price}", "https://example.com/legal"])

    def test_unreviewed_drafts_never_ship(self):
        localize.publish(self.draft(reviewed=False))
        self.assertNotIn("es", localize.read(self.catalog)["strings"]["Level {level}"]["localizations"])

    def test_reviewed_translation_publishes(self):
        localize.publish(self.draft())
        self.assertEqual(localize.read(self.catalog)["strings"]["Level {level}"]["localizations"]["es"]["stringUnit"]["value"], "Nivel {level}")

    def test_stale_source_rejected(self):
        with self.assertRaises(ValueError):
            localize.publish(self.draft(sourceHash="stale"))

    def test_safety_review_required(self):
        with self.assertRaises(ValueError):
            localize.publish(self.draft("Isolate before repair.", translation="Corta el suministro antes de reparar."))

    def test_reviewed_safety_translation(self):
        localize.publish(self.draft("Isolate before repair.", translation="Corta el suministro antes de reparar.", safetyReviewed=True))
        localize.validate()

    def test_dry_run_never_calls_provider(self):
        with patch.object(localize, "request_translations") as provider:
            localize.translate("fr", dry_run=True)
            provider.assert_not_called()

    def test_release_requires_complete_language(self):
        localize.publish(self.draft())
        with self.assertRaises(ValueError):
            localize.validate(release=True)

    def test_changed_content_drops_stale_catalogue(self):
        localize.publish(self.draft())
        localize.write(self.manifest, {"entries": {"New copy": {"contexts": ["copy.new"], "requiresSafetyReview": False}}})
        localize.sync_catalog()
        self.assertEqual(set(localize.read(self.catalog)["strings"]), {"New copy"})

    def test_missing_credentials_fail_before_network(self):
        with patch.dict(localize.os.environ, {}, clear=True), patch.object(localize, "request_translations") as provider:
            with self.assertRaises(ValueError):
                localize.translate("fr")
            provider.assert_not_called()


class MetadataTests(unittest.TestCase):
    def setUp(self):
        self.metadata = json.loads(PATH.read_text(encoding="utf-8"))

    def test_all_draft_metadata_limits_and_links(self):
        validate_metadata(self.metadata)

    def test_multibyte_keyword_limit(self):
        data = copy.deepcopy(self.metadata)
        data["localizations"]["es-ES"]["keywords"] = "é" * 51
        with self.assertRaises(AssertionError):
            validate_metadata(data)

    def test_required_privacy_link(self):
        data = copy.deepcopy(self.metadata)
        data["localizations"]["en-GB"]["description"] = "Missing legal links"
        with self.assertRaises(AssertionError):
            validate_metadata(data)


if __name__ == "__main__":
    unittest.main()
