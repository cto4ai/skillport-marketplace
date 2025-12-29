---
name: soil-data-analyzer
description: >
  Analyzes soil test data files (CSV, JSON, Excel), providing statistical summaries,
  nutrient assessments, pH analysis, and agronomic recommendations. Extends the
  data-analyzer skill with soil science-specific analytics.
---

# Soil Data Analyzer

Analyze soil test data with specialized agronomic insights, nutrient assessments, and quality checks.

## When to Use

- User asks to "analyze soil data" or "analyze soil test results"
- User has CSV/JSON/Excel files with soil parameters (pH, nutrients, etc.)
- User wants nutrient deficiency assessments or fertility recommendations
- User asks about soil quality or test result interpretation
- Data contains columns like: pH, N, P, K, OM, CEC, EC, or similar soil parameters

## Workflow

### 1. Identify the Data File

Ask the user for the file path or have them provide the data directly. Common soil data formats include lab reports, field sampling results, or precision agriculture exports.

### 2. Run Basic Analysis

Run the soil analysis script:
```bash
python scripts/analyze_soil_data.py <file-path>
```

The script outputs:
- Row and column counts
- Column types with soil parameter detection
- Missing value counts per column
- Basic statistics for numeric columns
- **Soil-specific metrics:**
  - pH classification (acidic/neutral/alkaline)
  - Macronutrient levels (N, P, K) with sufficiency ratings
  - Organic matter percentage assessment
  - CEC (Cation Exchange Capacity) interpretation
  - Salinity assessment (EC readings)
  - Nutrient ratio analysis (Ca:Mg, K:Mg)
- Sample of first 5 rows

### 3. Generate Soil Quality Report (Optional)

For deeper soil-specific quality analysis:
```bash
python scripts/soil_quality_check.py <file-path>
```

This checks for:
- Duplicate sample rows
- Columns with high null percentage
- Outliers in soil parameters (using agronomic ranges)
- pH values outside normal range (3.5-10.0)
- Nutrient imbalances
- Suspect readings (negative values, impossible combinations)
- Spatial inconsistencies (if GPS coordinates present)

### 4. Present Results

Summarize findings in a clear format with:
- Data overview and quality assessment
- Nutrient status summary (deficient/adequate/excessive)
- pH management recommendations
- Fertility recommendations based on typical crop requirements
- Flags for any data quality issues

## Recognized Soil Parameters

The analyzer automatically detects and interprets these common soil test parameters:

| Parameter | Common Column Names | Unit |
|-----------|---------------------|------|
| pH | ph, soil_ph, pH_water, pH_CaCl2 | - |
| Nitrogen | N, nitrogen, NO3, NH4, total_N | ppm, mg/kg, % |
| Phosphorus | P, phosphorus, Olsen_P, Bray_P, Mehlich_P | ppm, mg/kg |
| Potassium | K, potassium | ppm, mg/kg, meq/100g |
| Organic Matter | OM, organic_matter, SOM | % |
| CEC | CEC, cation_exchange | meq/100g, cmol/kg |
| EC | EC, electrical_conductivity, salinity | dS/m, mS/cm |
| Calcium | Ca, calcium | ppm, meq/100g |
| Magnesium | Mg, magnesium | ppm, meq/100g |
| Sulfur | S, sulfur, SO4 | ppm |
| Micronutrients | Fe, Mn, Zn, Cu, B, Mo | ppm |
| Texture | sand, silt, clay, texture_class | % or class |

## Reference Documentation

See `references/soil_parameters.md` for detailed information on:
- Optimal ranges for different crops
- Nutrient interpretation guidelines
- Regional considerations
- Lab method differences

See `references/supported_formats.md` for details on supported file formats.

## Example

**User:** "Analyze the soil test results in field_samples_2024.csv"

**Assistant:**
1. Runs `python scripts/analyze_soil_data.py field_samples_2024.csv`
2. Presents summary: "Your dataset has 150 soil samples across 12 parameters..."
3. Highlights soil status: "Average pH is 6.2 (slightly acidic). Phosphorus levels are low in 45% of samples."
4. Recommends: "Consider lime application to raise pH. Phosphorus supplementation recommended for low-P fields."
5. Flags issues: "Note: 3 samples have missing potassium values."
