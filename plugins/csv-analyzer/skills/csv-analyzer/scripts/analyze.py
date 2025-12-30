#!/usr/bin/env python3
"""CSV analysis utilities."""

import csv
import statistics
from pathlib import Path


def load_csv(file_path: str) -> list[dict]:
    """Load CSV file and return list of row dicts."""
    with open(file_path, 'r', newline='') as f:
        reader = csv.DictReader(f)
        return list(reader)


def get_numeric_column(rows: list[dict], column: str) -> list[float]:
    """Extract numeric values from a column."""
    values = []
    for row in rows:
        try:
            values.append(float(row[column]))
        except (ValueError, KeyError):
            pass
    return values


def column_stats(values: list[float]) -> dict:
    """Compute statistics for a numeric column."""
    if not values:
        return {'error': 'No numeric values found'}
    
    return {
        'count': len(values),
        'mean': statistics.mean(values),
        'median': statistics.median(values),
        'stdev': statistics.stdev(values) if len(values) > 1 else 0,
        'min': min(values),
        'max': max(values),
    }
