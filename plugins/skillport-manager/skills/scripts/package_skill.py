#!/usr/bin/env python3
"""
Package a skill directory into a .skill file (zip archive).

Usage:
  python package_skill.py <skill-directory> [output-directory]

Creates <output-directory>/skill-name.skill (defaults to current directory)
"""

import sys
import zipfile
from pathlib import Path


def package_skill(skill_path: str, output_dir: str = None) -> str:
    """Create .skill zip from skill directory."""
    skill_dir = Path(skill_path).resolve()

    if not skill_dir.exists():
        return f"Error: directory not found: {skill_path}"

    if not skill_dir.is_dir():
        return f"Error: not a directory: {skill_path}"

    # Validate SKILL.md exists
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        return f"Error: SKILL.md not found in {skill_path}"

    skill_name = skill_dir.name

    # Determine output path
    if output_dir:
        out_path = Path(output_dir).resolve()
        out_path.mkdir(parents=True, exist_ok=True)
    else:
        out_path = Path.cwd()

    output_file = out_path / f"{skill_name}.skill"

    # Create zip archive
    with zipfile.ZipFile(output_file, 'w', zipfile.ZIP_DEFLATED) as zf:
        for file_path in skill_dir.rglob('*'):
            if file_path.is_file():
                # Archive path includes skill name as root folder
                arcname = f"{skill_name}/{file_path.relative_to(skill_dir)}"
                zf.write(file_path, arcname)

    return str(output_file)


def main():
    if len(sys.argv) < 2:
        print("Usage: python package_skill.py <skill-directory> [output-directory]", file=sys.stderr)
        sys.exit(1)

    skill_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None

    result = package_skill(skill_path, output_dir)

    if result.startswith("Error:"):
        print(result, file=sys.stderr)
        sys.exit(1)
    else:
        print(result)


if __name__ == "__main__":
    main()
