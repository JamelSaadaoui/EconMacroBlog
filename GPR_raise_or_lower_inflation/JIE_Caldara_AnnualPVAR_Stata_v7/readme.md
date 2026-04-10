# JIE annual panel-VAR Stata archive

This package builds the annual-panel figures requested from **Caldara, Conlisk, Iacoviello, and Penn (2026)** using the uploaded file **`datapanelGPR_long.xlsx`**.

## What is included

The archive contains:

- a Stata master script
- one Stata do-file for each requested figure:
  - Figure 3
  - Figure 4
  - Figure 5
  - Figure 6
  - Figure 7
  - Figure 9
- a Mata backend that simulates the Jeffreys-prior posterior for pooled and country-by-country VARs
- a sample-audit script
- notes on implementation choices and sample construction

## What this package is designed to do

The paper’s annual figures are pooled **Bayesian** panel VAR exercises with one lag, common slopes across countries, country demeaning for the pooled specifications, and Cholesky identification.

This package therefore does **not** use `xtvar` for these figures. Instead it uses:

- **Stata** for data handling, figure assembly, and graph production
- **Mata** for posterior simulation and impulse-response construction

That is the closest Stata-native route for the annual figures listed in your request.

## Required input file

This archive already includes `raw/datapanelGPR_long.xlsx`.

The preparation script first looks in the project root and then in `raw/`.
The current package assumes the working directory in Stata is the **unzipped project folder**.

## How to run

Open Stata in the project folder and run:

```stata
do code/00_run_all_requested_figures.do
```

## Main folders

- `code/` — runnable do-files
- `code/lib/` — Mata backend
- `docs/` — implementation notes and sample checks
- `output/derived/` — intermediate `.dta` files with IRFs
- `output/figures/` — exported figures
- `output/logs/` — Stata logs

## Default controls

The defaults are set in `code/00_config.do`:

- lag length: `1`
- IRF horizon: `10`
- posterior draws: `5000`
- minimum country sample for unit-by-unit figures: `60`
- seed: `20260407`

You can edit those values in one place before running the package.

## Variable systems by figure

### Figure 3
`gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt`

### Figure 4
`gpa_country gpt_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt`

### Figure 5
`gpr_global gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt`

### Figure 6
Baseline system:
`gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt`

Narrative system:
`gpr_narrative gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt`

### Figure 7
`gpr_country inflation_ppt gdp_pct`

### Figure 9
`gpr_country gpr_foreign inflation_ppt gdp_pct`

## Important implementation notes

1. **Pooled figures (3–6, pooled lines in 7 and 9)**  
   The pooled estimator is implemented as a one-lag Bayesian VAR with a Jeffreys prior. Country fixed effects are handled by demeaning each system variable by country on the figure-specific raw complete-case sample.

2. **Country-by-country figures (7 and 9)**  
   Each country is estimated separately with a constant and one lag. Countries are retained if they have at least `60` nonmissing annual observations in the relevant system before lag construction.

3. **Narrative figure**  
   Figure 6 uses the provided `gpr_narrative` series directly from `datapanelGPR_long.xlsx`. The package does not reconstruct the historical screening step of Appendix B from scratch.

4. **GDP and trade transformations**  
   The uploaded annual file already provides transformed working variables such as `gdp_pct` and `trade_to_gdp_ppt`. The code therefore does not attempt to rebuild the paper’s earlier raw-data detrending pipeline from outside sources.

5. **Posterior simulation**  
   The paper describes Gibbs sampling under an uninformative Jeffreys prior. The Mata backend here draws directly from the corresponding conjugate posterior kernel for the reduced-form VAR, which targets the same posterior object for this setup.

## Expected sample checks from the uploaded file

See `docs/sample_checks.md`.

## Outputs

For each requested figure, the package saves:

- a `.dta` file with the IRFs used for graphing
- a `.gph` graph
- a `.png` export

## Monthly file

The uploaded `vardata_replication.xlsx` is **not used** in this archive because your request here concerns the annual panel figures only.

A copy of the paper PDF is also included in `reference/` for convenience.

