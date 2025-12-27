#!/usr/bin/env python3
"""
Install skill files to disk from JSON input.

Usage:
  echo '{"name": "...", "files": [...]}' | python install_skill.py --path <dir>

Reads JSON from stdin with structure:
{
  "name": "skill-name",
  "files": [
    {"path": "SKILL.md", "content": "..."},
    {"path": "scripts/foo.py", "content": "...", "encoding": "base64"}
  ]
}

Creates <path>/{name}/ and writes all files, handling base64-encoded
binary files automatically.
"""

import json
import sys
import base64
from pathlib import Path


def install_skill(data: dict, output_path: Path) -> str:
    """Install skill files to disk."""
    name = data.get("name")
    files = data.get("files", [])

    if not name:
        return "Error: missing 'name' field"

    if not files:
        return "Error: no files to install"

    # Create skill directory
    skill_dir = output_path.resolve() / name
    skill_dir.mkdir(parents=True, exist_ok=True)

    results = [f"Created {skill_dir}/"]

    for file_info in files:
        path = file_info.get("path")
        content = file_info.get("content", "")
        encoding = file_info.get("encoding")

        if not path:
            continue

        # Create subdirectories if needed
        file_path = skill_dir / path
        file_path.parent.mkdir(parents=True, exist_ok=True)

        # Handle binary vs text files
        if encoding == "base64":
            # Decode base64 and write as binary
            binary_content = base64.b64decode(content)
            file_path.write_bytes(binary_content)
            size_str = format_size(len(binary_content))
            results.append(f"  - {path} ({size_str}, binary)")
        else:
            # Write as text
            file_path.write_text(content)
            size_str = format_size(len(content.encode('utf-8')))
            results.append(f"  - {path} ({size_str})")

    return "\n".join(results)


def format_size(size_bytes: int) -> str:
    """Format bytes as human-readable size."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    else:
        return f"{size_bytes / (1024 * 1024):.1f} MB"


def main():
    # Parse --path argument
    if len(sys.argv) < 3 or sys.argv[1] != '--path':
        print("Usage: echo '{...}' | python install_skill.py --path <dir>", file=sys.stderr)
        sys.exit(1)

    output_path = Path(sys.argv[2])

    # Read JSON from stdin
    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        print(f"Error: invalid JSON input - {e}", file=sys.stderr)
        sys.exit(1)

    result = install_skill(data, output_path)
    print(result)


if __name__ == "__main__":
    main()
