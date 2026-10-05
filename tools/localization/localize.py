"""Build-time translation. No credentials or translation network calls in the iOS app."""
import argparse
from collections import Counter
import hashlib
import json
import os
from pathlib import Path
import re
import sys
import time
from urllib import error, request
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "tools/localization/source.json"
CATALOG = ROOT / "PipeBossAI/Content/Localizable.xcstrings"
TOKEN = re.compile(r"\{[a-zA-Z][a-zA-Z0-9_]*\}")
PROTECTED = re.compile(r"\{[a-zA-Z][a-zA-Z0-9_]*\}|PipeBoss AI|PipeBoss Pro|https?://[^\s]+")
TARGETS = {"es": "ES", "fr": "FR", "de": "DE", "pt-BR": "PT-BR"}


def read(path):
    return json.loads(Path(path).read_text(encoding="utf-8"))


def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    temporary.replace(path)


def signature(source):
    return hashlib.sha256(source.encode("utf-8")).hexdigest()


def validate_translation(source, target):
    if not isinstance(target, str) or not target.strip():
        raise ValueError("Empty translation")
    if Counter(TOKEN.findall(source)) != Counter(TOKEN.findall(target)):
        raise ValueError("Translation changed named placeholders")
    for literal in PROTECTED.findall(source):
        if source.count(literal) != target.count(literal):
            raise ValueError("Translation changed a brand, URL, or placeholder")


def protected_xml(source):
    root = ET.Element("text")
    cursor = 0
    last = None
    for match in PROTECTED.finditer(source):
        preceding = source[cursor:match.start()]
        if last is None:
            root.text = preceding
        else:
            last.tail = preceding
        last = ET.SubElement(root, "keep")
        last.text = match.group()
        cursor = match.end()
    if last is None:
        root.text = source
    else:
        last.tail = source[cursor:]
    return ET.tostring(root, encoding="unicode")


def request_translations(sources, locale, key, glossary=None):
    endpoint = "https://api-free.deepl.com/v2/translate" if key.endswith(":fx") else "https://api.deepl.com/v2/translate"
    body = {
        "text": [protected_xml(s) for s in sources], "source_lang": "EN", "target_lang": TARGETS[locale],
        "tag_handling": "xml", "ignore_tags": ["keep"], "preserve_formatting": True,
        "context": "Offline plumbing training simulation for apprentices. Keep safe isolation, professional escalation and repair order precise. Never imply real-world certification. Short practical UI copy.",
    }
    if glossary:
        body["glossary_id"] = glossary
    req = request.Request(endpoint, data=json.dumps(body).encode(), headers={
        "Authorization": "DeepL-Auth-Key " + key, "Content-Type": "application/json",
    })
    for attempt in range(4):
        try:
            with request.urlopen(req, timeout=45) as response:
                translations = json.load(response)["translations"]
            if len(translations) != len(sources):
                raise ValueError("Translation response count mismatch")
            result = []
            for source, item in zip(sources, translations):
                target = "".join(ET.fromstring(item["text"]).itertext())
                validate_translation(source, target)
                result.append(target)
            return result
        except error.HTTPError as exc:
            if exc.code in (429, 500, 502, 503, 504) and attempt < 3:
                time.sleep(2 ** attempt)
                continue
            # Never log headers, key or provider response bodies.
            raise RuntimeError(f"Translation provider HTTP {exc.code}; check quota and credentials.") from None
        except error.URLError:
            if attempt == 3:
                raise RuntimeError("Translation network request failed after bounded retries.") from None
            time.sleep(2 ** attempt)


def sync_catalog():
    manifest = read(MANIFEST)
    previous = read(CATALOG) if CATALOG.exists() else {"strings": {}}
    strings = {}
    for source, info in manifest["entries"].items():
        entry = previous["strings"].get(source, {})
        entry["comment"] = "; ".join(info["contexts"])
        entry["extractionState"] = "manual"
        entry.setdefault("localizations", {})["en"] = {"stringUnit": {"state": "translated", "value": source}}
        strings[source] = entry
    write(CATALOG, {"sourceLanguage": "en", "version": "1.0", "strings": strings})


def translate(locale, dry_run=False, glossary=None):
    manifest = read(MANIFEST)["entries"]
    path = ROOT / f"tools/localization/drafts/{locale}.json"
    draft = read(path) if path.exists() else {"locale": locale, "entries": {}}
    if draft["locale"] != locale:
        raise ValueError("Cached draft locale does not match the requested language")
    draft["entries"] = {source: entry for source, entry in draft["entries"].items()
                        if source in manifest and entry.get("sourceHash") == signature(source)}
    catalog = read(CATALOG)["strings"]
    pending = [s for s in manifest if locale not in catalog.get(s, {}).get("localizations", {})
               and draft["entries"].get(s, {}).get("sourceHash") != signature(s)]
    print(f"{locale}: {len(pending)} missing strings, {sum(map(len, pending))} source characters.")
    if dry_run:
        return
    if not pending:
        write(path, draft)
        validate_draft(path)
        return
    key = os.environ.get("DEEPL_AUTH_KEY")
    if not key:
        raise ValueError("Set DEEPL_AUTH_KEY locally or as a CI secret. Never put it in the app or chat.")
    for start in range(0, len(pending), 25):
        batch = pending[start:start + 25]
        translations = request_translations(batch, locale, key, glossary)
        for source, target in zip(batch, translations):
            draft["entries"][source] = {
                "translation": target, "sourceHash": signature(source), "reviewed": False,
                "safetyReviewed": False, "requiresSafetyReview": manifest[source]["requiresSafetyReview"],
            }
        write(path, draft)
        print(f"Saved draft batch {start // 25 + 1}. No translations published.")
    validate_draft(path)


def publish(path):
    draft = read(path)
    locale = draft["locale"]
    if locale not in TARGETS:
        raise ValueError("Unsupported target locale")
    catalog = read(CATALOG)
    manifest = read(MANIFEST)["entries"]
    accepted = 0
    for source, entry in draft["entries"].items():
        if entry.get("reviewed") is not True:
            continue
        if source not in manifest or entry.get("sourceHash") != signature(source):
            raise ValueError("Reviewed draft is stale. Export content and translate again.")
        if manifest[source]["requiresSafetyReview"] and entry.get("safetyReviewed") is not True:
            raise ValueError("Safety-sensitive content needs explicit trade/safety review.")
        validate_translation(source, entry["translation"])
        catalog["strings"][source]["localizations"][locale] = {
            "stringUnit": {"state": "translated", "value": entry["translation"]}
        }
        accepted += 1
    write(CATALOG, catalog)
    print(f"Published {accepted} explicitly reviewed entries for {locale}.")


def validate_draft(path):
    draft = read(path)
    if draft["locale"] not in TARGETS:
        raise ValueError("Unsupported draft locale")
    manifest = read(MANIFEST)["entries"]
    for source, entry in draft["entries"].items():
        if source not in manifest or entry.get("sourceHash") != signature(source):
            raise ValueError("Draft contains obsolete source content")
        for flag in ("reviewed", "safetyReviewed"):
            if type(entry.get(flag)) is not bool:
                raise ValueError("Draft review flags must be booleans")
        validate_translation(source, entry["translation"])
    print(f"{draft['locale']}: {len(draft['entries'])} valid draft entries. Not published.")


def import_manual(locale, path):
    """Bootstrap hand-authored pilot copy; never use for machine-translation output."""
    catalog = read(CATALOG)
    translations = read(path)
    for source, target in translations.items():
        if source not in catalog["strings"]:
            raise ValueError(f"Unknown source in manual copy: {source}")
        validate_translation(source, target)
        catalog["strings"][source]["localizations"][locale] = {
            "stringUnit": {"state": "translated", "value": target}
        }
    write(CATALOG, catalog)
    print(f"Imported {len(translations)} hand-authored pilot strings; native-speaker and trade review still required before release.")


def validate(release=False):
    manifest = read(MANIFEST)["entries"]
    catalog = read(CATALOG)
    if set(manifest) != set(catalog["strings"]):
        raise ValueError("Content and catalogue differ; re-export and sync.")
    counts = Counter()
    for source, entry in catalog["strings"].items():
        for locale, value in entry["localizations"].items():
            validate_translation(source, value["stringUnit"]["value"])
            if value["stringUnit"]["state"] != "translated":
                raise ValueError("Unreviewed translation in shipping catalogue")
            counts[locale] += 1
    for locale, count in sorted(counts.items()):
        print(f"{locale}: {count}/{len(manifest)} strings ({count / len(manifest):.1%})")
        if release and count != len(manifest):
            raise ValueError(f"{locale} is incomplete; do not advertise full language support.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("sync")
    tr = sub.add_parser("translate")
    tr.add_argument("locale", choices=TARGETS)
    tr.add_argument("--dry-run", action="store_true")
    tr.add_argument("--glossary-id")
    pub = sub.add_parser("publish")
    pub.add_argument("draft", type=Path)
    draft_check = sub.add_parser("validate-draft")
    draft_check.add_argument("draft", type=Path)
    seed = sub.add_parser("import-manual")
    seed.add_argument("locale", choices=TARGETS)
    seed.add_argument("path", type=Path)
    seed.add_argument("--hand-authored", action="store_true", required=True)
    val = sub.add_parser("validate")
    val.add_argument("--release", action="store_true")
    args = parser.parse_args()
    if args.command == "sync":
        sync_catalog()
    elif args.command == "translate":
        translate(args.locale, args.dry_run, args.glossary_id)
    elif args.command == "publish":
        publish(args.draft)
    elif args.command == "validate-draft":
        validate_draft(args.draft)
    elif args.command == "import-manual":
        import_manual(args.locale, args.path)
    else:
        validate(args.release)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, RuntimeError, OSError) as exc:
        print(f"Localization: {exc}", file=sys.stderr)
        sys.exit(1)
