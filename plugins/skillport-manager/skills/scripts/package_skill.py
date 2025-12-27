#!/usr/bin/env python3
"""
Package a skill directory into a .skill file (zip archive).

Usage:
  python package_skill.py /home/claude/skill-name

Creates /mnt/user-data/outputs/skill-name.skill
"""

import sys
import os
import zipfile
from pathlib import Path


def package_skill(skill_path: str) -> str:
    """Create .skill zip from skill directory."""
    skill_dir = Path(skill_path)

    if not skill_dir.exists():
        return f"Error: directory not found: {skill_path}"

    if not skill_dir.is_dir():
        return f"Error: not a directory: {skill_path}"

    # Validate SKILL.md exists
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return f"Error: SKILL.md not found in {skill_path}"

    skill_name = skill_dir.name
    output_dir = Path("/mnt/user-data/outputs")
    output_dir.mkdir(parents=True, exist_ok=True)

    output_path = output_dir / f"{skill_name}.skill"

    # Create zip archive
    with zipfile.ZipFile(output_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for file_path in skill_dir.rglob('*'):
            if file_path.is_file():
                # Archive path includes skill name as root folder
                arcname = f"{skill_name}/{file_path.relative_to(skill_dir)}"
                zf.write(file_path, arcname)

    return str(output_path)


def main():
    if len(sys.argv) < 2:
        print("Usage: python package_skill.py <skill-directory>", file=sys.stderr)
        sys.exit(1)

    skill_path = sys.argv[1]
    result = package_skill(skill_path)

    if result.startswith("Error:"):
        print(result, file=sys.stderr)
        sys.exit(1)
    else:
        print(result)


if __name__ == "__main__":
    main()
