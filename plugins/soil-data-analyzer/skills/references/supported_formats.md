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
sample_id,field,ph,nitrogen,phosphorus,potassium,organic_matter
S001,North Field,6.2,25,18,145,3.2
S002,North Field,6.4,22,15,138,2.9
S003,South Field,5.8,30,12,110,2.5
```

## JSON Files (.json)

### Requirements
- Must be valid JSON
- Array of objects (each object = one sample)
- Or single object (treated as one sample)

### Limitations
- Deeply nested structures are flattened to first level
- Arrays within objects are converted to strings

### Example
```json
[
  {"sample_id": "S001", "field": "North", "ph": 6.2, "N": 25, "P": 18, "K": 145},
  {"sample_id": "S002", "field": "North", "ph": 6.4, "N": 22, "P": 15, "K": 138}
]
```

## Excel Files (.xlsx, .xlsm)

### Requirements
- Modern Excel format (.xlsx or .xlsm)
- First row must contain column headers
- Reads the active (first) sheet only

### Limitations
- Legacy .xls format not supported
- Requires `openpyxl` library (pip install openpyxl)
- Formulas are read as calculated values
- Charts and images are ignored
- Multiple sheets: only the first/active sheet is analyzed

### Example
Standard Excel spreadsheet with headers in row 1:

| sample_id | field | ph | N | P | K | OM |
|-----------|-------|----|---|---|---|----|
| S001 | North | 6.2 | 25 | 18 | 145 | 3.2 |
| S002 | North | 6.4 | 22 | 15 | 138 | 2.9 |

## Column Naming Conventions

The analyzer automatically recognizes common soil parameter names:

### pH
- `ph`, `soil_ph`, `pH`, `pH_water`, `pH_CaCl2`, `pH_h2o`

### Macronutrients
- Nitrogen: `N`, `nitrogen`, `NO3`, `NH4`, `total_N`, `nitrate`
- Phosphorus: `P`, `phosphorus`, `Olsen_P`, `Bray_P`, `Mehlich_P`
- Potassium: `K`, `potassium`, `exchangeable_K`

### Secondary Nutrients
- Calcium: `Ca`, `calcium`
- Magnesium: `Mg`, `magnesium`
- Sulfur: `S`, `sulfur`, `SO4`

### Other Parameters
- Organic Matter: `OM`, `organic_matter`, `SOM`, `organic_C`
- CEC: `CEC`, `cation_exchange`, `cation_exchange_capacity`
- EC: `EC`, `electrical_conductivity`, `salinity`

### Texture
- `sand`, `silt`, `clay`, `sand_pct`, `silt_pct`, `clay_pct`

### Micronutrients
- `Fe`, `iron`
- `Mn`, `manganese`
- `Zn`, `zinc`
- `Cu`, `copper`
- `B`, `boron`

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
- Empty cells in Excel

## Statistics Calculated

For numeric columns:
- **count**: Number of non-null values
- **min/max**: Minimum and maximum values
- **mean**: Arithmetic mean
- **std**: Standard deviation
- **median**: Middle value (50th percentile)

## Soil-Specific Quality Checks

The quality checker looks for:

1. **Duplicate samples**: Exact matches across all columns
2. **High null columns**: Columns with >50% missing values
3. **Agronomic outliers**: Values outside expected ranges for soil parameters
4. **Negative values**: Invalid for most soil measurements
5. **Texture inconsistencies**: Sand + Silt + Clay ≠ 100%
6. **Nutrient imbalances**: Ca:Mg ratio, K:Mg ratio outside optimal ranges
