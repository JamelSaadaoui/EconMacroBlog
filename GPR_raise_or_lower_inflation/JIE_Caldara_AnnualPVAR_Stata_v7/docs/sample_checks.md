# Sample checks from the uploaded annual file

The counts below come directly from `datapanelGPR_long.xlsx` as uploaded in this workspace.

## Raw complete-case observations

- Figures 3, 4, 5, and 6 systems: **3622** observations across **43** countries
- Figures 7 and 9 systems: **4919** observations across **44** countries

## Lag-valid observations with one lag and consecutive-year requirement

- Figures 3, 4, 5, and 6 systems: **3564** usable regression rows across **43** countries
- Figures 7 and 9 systems: **4869** usable regression rows across **44** countries

## Countries excluded by data availability in the paper-style annual setups

### Figures 3–6 pooled nine- and ten-variable annual systems
- **Hong Kong** has no observations for `milit_exp_to_gdp_ppt`, so the complete-case system drops it.

### Figures 7 and 9 country-by-country 60-year rule
- Countries with at least 60 nonmissing annual observations in the 3-variable and 4-variable systems: **43**
- Country below the threshold: **Ukraine** with **44** observations

## Notes

1. The raw complete-case counts line up closely with the paper’s discussion of about 3600 observations in the 9-variable pooled annual system.
2. The lag-valid count is smaller because the package requires valid adjacent annual observations within country when constructing the VAR lags.

