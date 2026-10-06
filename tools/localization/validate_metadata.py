"""Validate App Store limits without publishing or changing App Store Connect."""
import json
from pathlib import Path
from urllib.parse import urlparse

PATH = Path(__file__).resolve().parents[2] / "AppStoreAssets/Metadata/localizations.json"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def validate_metadata(data):
    require(data["publicationMode"] == "draft-only", "Metadata must remain draft-only until explicitly applied")
    for name in ("privacyPolicyURL", "termsOfUseURL", "standardEULAURL"):
        parsed = urlparse(data[name])
        require(parsed.scheme == "https" and parsed.netloc, f"Invalid {name}")
    for locale, entry in data["localizations"].items():
        for field, limit in (("name", 30), ("subtitle", 30), ("promotionalText", 170), ("description", 4000)):
            require(0 < len(entry[field]) <= limit, f"{locale}: {field} is {len(entry[field])}; limit {limit}")
        require(len(entry["keywords"].encode("utf-8")) <= 100, f"{locale}: keywords exceed 100 UTF-8 bytes")
        words = entry["keywords"].split(",")
        require(len(words) == len(set(w.casefold() for w in words)), f"{locale}: duplicate keywords")
        require(all(len(w) > 2 and w == w.strip() for w in words), f"{locale}: invalid keyword")
        for legal in ("privacyPolicyURL", "termsOfUseURL", "standardEULAURL"):
            require(data[legal] in entry["description"], f"{locale}: missing {legal}")
        require(type(entry.get("releaseReady")) is bool, f"{locale}: releaseReady must be a boolean")


if __name__ == "__main__":
    data = json.loads(PATH.read_text(encoding="utf-8"))
    validate_metadata(data)
    for locale, entry in data["localizations"].items():
        print(f"{locale}: valid limits; {len(entry['keywords'].encode('utf-8'))} keyword bytes; ready={entry['releaseReady']}")
