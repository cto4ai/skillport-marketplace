# Supported Data Formats

## CSV Files (.csv)

### Requirements
- First row must contain column headers
- Comma-separated values (standard CSV format)
- UTF-8 encoding (with or without BOM)

### Limitations
- Complex nested structures not supported
- Multi-line cell values may not parse correctly
- Maximum recommended file size: 100MB

### Example
```csv
name,age,city,salary
Alice,30,New York,75000
Bob,25,Los Angeles,65000
```

## JSON Files (.json)

### Requirements
- Must be valid JSON
- Array of objects (each object = one row)
- Or single object (treated as one row)

### Limitations
- Deeply nested structures are flattened to first level
- Arrays within objects are converted to strings

### Example
```json
[
  {"name": "Alice", "age": 30, "city": "New York"},
  {"name": "Bob", "age": 25, "city": "Los Angeles"}
]
```

## Data Type Detection

The analyzer automatically detects column types:

| Type | Detection Rule |
|------|----------------|
| numeric | >80% of values parse as numbers |
| string | Default for non-numeric data |
| empty | Column contains no non-null values |

## Missing Value Handling

The following are treated as missing/null:
- Empty strings `""`
- Literal `null` in JSON
- Missing keys in JSON objects

## Statistics Calculated

For numeric columns:
- **count**: Number of non-null values
- **min/max**: Minimum and maximum values
- **mean**: Arithmetic mean
- **median**: Middle value (50th percentile)

## Quality Checks

The quality checker looks for:

1. **Duplicate rows**: Exact matches across all columns
2. **High null columns**: Columns with >50% missing values
3. **Outliers**: Values outside 1.5x IQR from quartiles
