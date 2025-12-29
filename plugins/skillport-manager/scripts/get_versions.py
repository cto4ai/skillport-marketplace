#!/usr/bin/env python3
"""
Extract versions from all installed skills.

Reads plugin.json from each skill in /mnt/skills/user/ and outputs
a JSON array of {name, version} objects suitable for check_updates.

Output:
[
  {"name": "skillport-manager", "version": "1.0.0"},
  {"name": "pdf", "version": "2.1.0"}
]
"""

import json
import sys
from pathlib import Path


def get_versions() -> list:
    """Get versions from all installed skills."""
    skills_dir = Path("/mnt/skills/user")
    versions = []

    if not skills_dir.exists():
        return versions

    for skill_dir in skills_dir.iterdir():
        if not skill_dir.is_dir():
            continue

        plugin_json = skill_dir / "plugin.json"
        if plugin_json.exists():
            try:
                data = json.loads(plugin_json.read_text())
                name = data.get("name", skill_dir.name)
                version = data.get("version")
                if version:
                    versions.append({"name": name, "version": version})
            except (json.JSONDecodeError, IOError):
                # Skip skills with invalid plugin.json
                pass

    return versions


def main():
    versions = get_versions()
    print(json.dumps(versions, indent=2))


if __name__ == "__main__":
    main()
