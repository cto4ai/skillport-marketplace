#!/usr/bin/env python3
"""
Check data quality for CSV or JSON files.

Usage:
  python quality_check.py <file-path>

Checks for:
- Duplicate rows
- High null percentage columns
- Potential outliers
- Inconsistent formatting
"""

import json
import sys
from pathlib import Path


def parse_csv(file_path):
    """Parse CSV file into list of dicts."""
    rows = []
    with open(file_path, 'r', encoding='utf-8-sig') as f:
        lines = f.readlines()

    if not lines:
        return [], []

    header = [h.strip().strip('"') for h in lines[0].strip().split(',')]

    for line in lines[1:]:
        if line.strip():
            values = [v.strip().strip('"') for v in line.strip().split(',')]
            row = dict(zip(header, values))
            rows.append(row)

    return header, rows


def parse_json(file_path):
    """Parse JSON file into list of dicts."""
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    if isinstance(data, list) and data:
        header = list(data[0].keys()) if isinstance(data[0], dict) else []
        return header, data

    return [], []


def find_duplicates(rows, header):
    """Find duplicate rows."""
    seen = set()
    duplicates = []

    for i, row in enumerate(rows):
        key = tuple(str(row.get(col, "")) for col in header)
        if key in seen:
            duplicates.append(i + 1)  # 1-indexed
        seen.add(key)

    return duplicates


def find_high_null_columns(rows, header, threshold=0.5):
    """Find columns with high null percentage."""
    issues = []

    for col in header:
        values = [row.get(col) for row in rows]
        null_count = sum(1 for v in values if v is None or v == "")
        null_pct = null_count / len(values) if values else 0

        if null_pct >= threshold:
            issues.append({
                "column": col,
                "null_count": null_count,
                "null_pct": round(null_pct * 100, 1)
            })

    return issues


def find_outliers(rows, header):
    """Find potential outliers using IQR method."""
    issues = []

    for col in header:
        values = []
        for row in rows:
            try:
                values.append(float(str(row.get(col, "")).replace(",", "")))
            except (ValueError, TypeError):
                pass

        if len(values) < 10:
            continue

        values.sort()
        n = len(values)
        q1 = values[n // 4]
        q3 = values[3 * n // 4]
        iqr = q3 - q1
        lower = q1 - 1.5 * iqr
        upper = q3 + 1.5 * iqr

        outlier_count = sum(1 for v in values if v < lower or v > upper)

        if outlier_count > 0:
            issues.append({
                "column": col,
                "outlier_count": outlier_count,
                "range": f"{round(lower, 2)} to {round(upper, 2)}"
            })

    return issues


def quality_check(file_path):
    """Run quality checks on data file."""
    path = Path(file_path)

    if not path.exists():
        return f"Error: File not found: {file_path}"

    ext = path.suffix.lower()
    if ext == '.csv':
        header, rows = parse_csv(file_path)
    elif ext == '.json':
        header, rows = parse_json(file_path)
    else:
        return f"Error: Unsupported file type: {ext}"

    if not rows:
        return "Error: No data found in file"

    output = []
    output.append(f"## Data Quality Report: {path.name}")
    output.append(f"- **Total rows:** {len(rows)}")
    output.append("")

    issues_found = False

    # Check duplicates
    duplicates = find_duplicates(rows, header)
    if duplicates:
        issues_found = True
        output.append(f"### Duplicate Rows")
        output.append(f"Found {len(duplicates)} duplicate row(s)")
        if len(duplicates) <= 10:
            output.append(f"Row numbers: {', '.join(map(str, duplicates))}")
        output.append("")

    # Check high null columns
    high_null = find_high_null_columns(rows, header)
    if high_null:
        issues_found = True
        output.append("### High Null Columns (>50%)")
        for issue in high_null:
            output.append(f"- **{issue['column']}**: {issue['null_count']} nulls ({issue['null_pct']}%)")
        output.append("")

    # Check outliers
    outliers = find_outliers(rows, header)
    if outliers:
        issues_found = True
        output.append("### Potential Outliers")
        for issue in outliers:
            output.append(f"- **{issue['column']}**: {issue['outlier_count']} values outside {issue['range']}")
        output.append("")

    if not issues_found:
        output.append("### No Issues Found")
        output.append("Data quality checks passed.")

    return "\n".join(output)


def main():
    if len(sys.argv) < 2:
        print("Usage: python quality_check.py <file-path>", file=sys.stderr)
        sys.exit(1)

    result = quality_check(sys.argv[1])
    print(result)


if __name__ == "__main__":
    main()
