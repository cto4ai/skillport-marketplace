#!/usr/bin/env python3
"""Helper utilities for test-editor-skill-2."""

import json
from pathlib import Path


def load_config(config_path: str = "config.json") -> dict:
    """Load configuration from JSON file."""
    path = Path(config_path)
    if not path.exists():
        return {}
    with open(path) as f:
        return json.load(f)


def save_config(config: dict, config_path: str = "config.json") -> None:
    """Save configuration to JSON file."""
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)


if __name__ == "__main__":
    print("Helper script loaded successfully")
