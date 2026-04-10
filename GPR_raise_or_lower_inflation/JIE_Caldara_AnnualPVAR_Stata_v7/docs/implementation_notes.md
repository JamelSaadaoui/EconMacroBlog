# Implementation notes

## 1. Why the archive does not use `xtvar` for these figures

The annual figures requested here are pooled Bayesian panel-VAR exercises, not Stata `xtvar` exercises.  
For that reason the package uses:

- Stata for data preparation, sample construction, and graphs
- Mata for posterior simulation and orthogonalized IRFs

`xtvar` can still be used later as a benchmark or robustness exercise, but not as the main estimator for Figures 3, 4, 5, 6, 7, and 9.

## 2. Pooled estimator

For Figures 3–6, and for the pooled blue line in Figures 7 and 9, the code does the following:

1. define the figure-specific raw complete-case sample
2. demean each system variable by country on that sample
3. construct the one-lag VAR design matrix using only valid adjacent annual observations within country
4. estimate the reduced-form VAR with a constant
5. simulate from the Jeffreys-prior posterior
6. compute orthogonalized IRFs using a Cholesky factorization of the simulated covariance matrix
7. store posterior 5th, 50th, and 95th percentiles

## 3. Country-by-country estimators

For Figures 7 and 9, the unit-by-unit estimator:

1. uses the raw variables rather than country-demeaned pooled variables
2. estimates a separate one-lag Bayesian VAR for each country
3. keeps countries with at least 60 nonmissing annual observations in the relevant system
4. aggregates country-specific IRFs using:
   - equal weights
   - inverse posterior-variance weights cell by cell

The band plotted in Figures 7 and 9 is the 90 percent band around the inverse-variance aggregate.

## 4. Sample construction

The code distinguishes between:

- **raw complete-case observations**: all variables in the figure’s system are observed in year `t`
- **lag-valid observations**: the row at `t` is complete and the required lagged row(s) are also complete, in the same country, with consecutive years

This matters because dropping missing values and then lagging the compressed series would create false adjacency. The Mata routines therefore rebuild the valid rows directly from panel and year identifiers.

## 5. Figure 6 narrative implementation

The paper’s Appendix B describes a residual-based narrative screening step.  
This archive does **not** rebuild that screening algorithm from historical sources. It uses the supplied `gpr_narrative` variable in the uploaded annual panel.

That is sufficient for reproducing the figure workflow from the provided data.

## 6. Transformations already embedded in the annual file

The uploaded file already contains the working transformed annual variables:

- `inflation_ppt`
- `gdp_pct`
- `trade_to_gdp_ppt`
- `money_growth_ppt`
- and the trimmed variants used for robustness exercises

Because those working series are already present, the archive does not attempt to recreate the authors’ earlier upstream winsorization and raw-data engineering pipeline.

## 7. What to compare to the paper

For these figures, the relevant comparison targets are:

- sign of the responses
- persistence
- timing of the peak
- relative ranking across variables
- broad similarity of pooled versus unit-by-unit estimates

The exact plotted magnitudes may differ slightly from the published figure because graph styling, posterior draw count, and any upstream preprocessing choices can affect the final display.

