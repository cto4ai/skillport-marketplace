---
name: data-analyzer
description: >
  Analyzes CSV and JSON data files, providing statistical summaries, data quality reports,
  and simple visualizations. Activates when the user asks to analyze data, summarize a dataset,
  or check data quality.
---

# Data Analyzer

Analyze structured data files (CSV, JSON) with statistical summaries and quality checks.

## When to Use

- User asks to "analyze this data" or "summarize this dataset"
- User wants statistics on a CSV or JSON file
- User asks about data quality or missing values
- User wants to understand the structure of their data

## Workflow

### 1. Identify the Data File

Ask the user for the file path or have them provide the data directly.

### 2. Analyze the Data

Run the analysis script:
```bash
python scripts/analyze_data.py <file-path>
```

The script outputs:
- Row and column counts
- Column types (numeric, string, date)
- Missing value counts per column
- Basic statistics for numeric columns (min, max, mean, median, std)
- Sample of first 5 rows

### 3. Generate Quality Report (Optional)

For deeper quality analysis:
```bash
python scripts/quality_check.py <file-path>
```

This checks for:
- Duplicate rows
- Columns with high null percentage
- Potential outliers in numeric columns
- Inconsistent formatting

### 4. Present Results

Summarize findings in a clear, readable format. Highlight any data quality issues.

## Reference Documentation

See `references/supported_formats.md` for details on supported file formats and limitations.

## Example

**User:** "Analyze the sales data in sales_2024.csv"

**Assistant:**
1. Runs `python scripts/analyze_data.py sales_2024.csv`
2. Presents summary: "Your dataset has 1,500 rows and 8 columns..."
3. Highlights any issues: "Note: The 'region' column has 23 missing values (1.5%)"
