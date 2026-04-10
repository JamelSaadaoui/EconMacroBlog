/*
================================================================================
Cross-Country Panel Regression Analysis:
"Do Geopolitical Risks Raise or Lower Inflation?"
================================================================================
Purpose: Analyze the transmission mechanism of country-specific geopolitical 
         risk (GPR) to inflation across countries at multiple time horizons
================================================================================
*/


/*
================================================================================
SECTION 1: PRELIMINARIES AND SETUP
================================================================================
Define global parameters and load data
*/

* Define sample period
global first_year = 1900          // Start year of sample
global last_year = 2023           // End year of sample (common endpoint)
global nreps "500"                // Number of bootstrap replications for quantile regressions

* Load and prepare dataset
use CICP_JIE.dta, clear
sort country year

* Restrict to common end date (some variables only updated through 2022)
drop if year > $last_year


/*
================================================================================
SECTION 2: VARIABLE GENERATION AND TRANSFORMATION
================================================================================
Create standardized transmission variables and outcome variables at multiple horizons
*/

* Standardize transmission mechanism variables (lagged by one year)
egen DD = std(L.debttogdp)              // Standardized debt-to-GDP ratio
egen TT = std(L.impexp_gdp_ratio)       // Standardized import-export ratio
egen MM = std(L.milit_exp_share)        // Standardized military expenditure share

* Generate outcome variables: inflation changes at different forward horizons (t to t+h)
gen d_inf_4 = F4.inflation_sig - L.inflation_sig    // 4-year ahead change
gen d_inf_3 = F3.inflation_sig - L.inflation_sig    // 3-year ahead change
gen d_inf_2 = F2.inflation_sig - L.inflation_sig    // 2-year ahead change
gen d_inf_1 = F.inflation_sig - L.inflation_sig     // 1-year ahead change
gen d_inf_0 = inflation_sig - L.inflation_sig       // Same-year change
gen inf_2 = F2.inflation_sig                        // 2-year ahead inflation level

* Create country-specific geopolitical risk variable
gen cgpr = sgprco

* Assess data quality: count observations per country
egen nobs = total(!missing(d_inf_2) & !missing(cgpr)), by(country)
tabulate country, summarize(nobs)

* Create economy-type specific inflation variables for subgroup analysis
gen inflation_afe = inflation_sig if afe == 1       // Advanced economy inflation
gen inflation_eme = inflation_sig if afe == 0       // Emerging market inflation

* Set panel structure for time-series cross-sectional analysis
xtset country year


/*
================================================================================
SECTION 3: REGRESSION MODELS AND TABLE 2 CONSTRUCTION
================================================================================
Run 8 model specifications across 5 time horizons (t, t+1, t+2, t+3, t+4)
Models test different subsamples and estimation methods

TABLE STRUCTURE:
  Model 1: Baseline OLS with country FE
  Model 2: Add global GPR control
  Model 3: Advanced economies subsample
  Model 4: Emerging markets subsample
  Model 5: Post-1950 subsample
  Models 6-8: Quantile regressions at 25th, 50th, 75th percentiles
================================================================================
*/

* Set variable labels for regression output
forvalues h = 0(1)4 {
    label var d_inf_`h' "Inflation"
}
label var cgpr "Country GPR"
label var gprh "Global GPR"
label var afe "D_{AE}"
label var dum_nwar "D_{WW}"
label var dum_post "D_{post1950}"
label var MM "Military"
label var DD "Debt"
label var TT "Trade"

* Get number of countries in sample for display
qui xtreg d_inf_0 cgpr   
global ncountry = e(N_g)


/* ============================================================================
   MODEL 1: BASELINE - OLS with country fixed effects, no controls
   ========================================================================== */

eststo: reghdfe d_inf_0 cgpr, absorb(country) cluster(country year)

gen cgpr1 = cgpr
label var cgpr1 "Baseline"

forvalues h = 0(1)4 {
    eststo: reghdfe d_inf_`h' cgpr1, absorb(country) cluster(country year)
    eststo m1_`h', refresh
    
    * Store model statistics
    global r2 = e(r2)
    local pr2 : di %7.2fc $r2
    global n = e(N)
    local N : di %8.0fc $n
    estadd local "N2" "`N'"
    estadd local "pr2" "`pr2'"
    estadd local "nc" "$ncountry" 
}


/* ============================================================================
   MODEL 2: ADD GLOBAL GPR CONTROL
   Specification includes global geopolitical risk to isolate country-specific effects
   ========================================================================== */

gen cgpr2 = cgpr
label var cgpr2 "Controlling for Global GPR"

forvalues h = 0(1)4 {
    eststo: reghdfe d_inf_`h' cgpr2 gprh, absorb(country) cluster(country year)
    eststo m2_`h', refresh
    
    global r2 = e(r2)
    local pr2 : di %7.2fc $r2
    global n = e(N)
    local N : di %8.0fc $n
    estadd local "N2" "`N'"
    estadd local "pr2" "`pr2'"
    estadd local "nc" "$ncountry" 
}


/* ============================================================================
   MODEL 3: ADVANCED ECONOMIES SUBSAMPLE
   Examines transmission mechanism in developed economies only
   ========================================================================== */

gen cgpr3 = cgpr
label var cgpr3 "Advanced Economies"

forvalues h = 0(1)4 {
    eststo: reghdfe d_inf_`h' cgpr3 if afe == 1, absorb(country) cluster(country year)
    eststo m3_`h', refresh
    
    global r2 = e(r2)
    local pr2 : di %7.2fc $r2
    global n = e(N)
    local N : di %8.0fc $n
    estadd local "N2" "`N'"
    estadd local "pr2" "`pr2'"
    estadd local "nc" "$ncountry" 
}


/* ============================================================================
   MODEL 4: EMERGING MARKETS SUBSAMPLE
   Examines transmission mechanism in emerging and developing economies
   ========================================================================== */

gen cgpr4 = cgpr
label var cgpr4 "Emerging Economies"

forvalues h = 0(1)4 {
    eststo: reghdfe d_inf_`h' cgpr4 if afe == 0, absorb(country) cluster(country year)
    eststo m4_`h', refresh
    
    global r2 = e(r2)
    local pr2 : di %7.2fc $r2
    global n = e(N)
    local N : di %8.0fc $n
    estadd local "N2" "`N'"
    estadd local "pr2" "`pr2'"
    estadd local "nc" "$ncountry" 
}


/* ============================================================================
   MODEL 5: POST-1950 SUBSAMPLE
   Restricts analysis to post-WWII period for institutional comparability
   ========================================================================== */

gen cgpr5 = cgpr
label var cgpr5 "Post-1950s"

forvalues h = 0(1)4 {
    eststo: reghdfe d_inf_`h' cgpr5 if dum_post == 1, absorb(country) cluster(country year)
    eststo m5_`h', refresh
    
    global r2 = e(r2)
    local pr2 : di %7.2fc $r2
    global n = e(N)
    local N : di %8.0fc $n
    estadd local "N2" "`N'"
    estadd local "pr2" "`pr2'"
    estadd local "nc" "$ncountry" 
}


/* ============================================================================
   MODEL 6: QUANTILE REGRESSION AT 25TH PERCENTILE
   Tests whether GPR effects differ at lower distribution of inflation changes
   ========================================================================== */

gen cgpr6 = cgpr
label var cgpr6 "q25"

forvalues h = 0(1)4 {
    bs, reps($nreps): xtqreg d_inf_`h' cgpr6, i(countrycode) q(.25)  
    eststo m6_`h'
    estadd local "nc" "$ncountry"
}


/* ============================================================================
   MODEL 7: QUANTILE REGRESSION AT 50TH PERCENTILE (MEDIAN)
   Tests median effects of GPR on inflation changes
   ========================================================================== */

gen cgpr7 = cgpr
label var cgpr7 "q50"

forvalues h = 0(1)4 {
    bs, reps($nreps): xtqreg d_inf_`h' cgpr7, i(countrycode) q(.5)  
    eststo m7_`h'
    estadd local "nc" "$ncountry"
}


/* ============================================================================
   MODEL 8: QUANTILE REGRESSION AT 75TH PERCENTILE
   Tests whether GPR effects differ at upper distribution of inflation changes
   ========================================================================== */

gen cgpr8 = cgpr
label var cgpr8 "q75"

forvalues h = 0(1)4 {
    bs, reps($nreps): xtqreg d_inf_`h' cgpr8, i(countrycode) q(.75)  
    eststo m8_`h'
    estadd local "nc" "$ncountry"
}


/*
================================================================================
SECTION 4: TABLE EXPORT
================================================================================
Export comprehensive regression table to output file
================================================================================
*/

* Model 1 Baseline results
esttab m1_0 m1_1 m1_2 m1_3 m1_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) nonum ///
    scalars("N2 Observations" "pr2 R^2" "nc Number of Countries") ///
    title(\label{table:panelmodels}Effects of an Increase in Country-Specific Geopolitical Risk) ///
    mgroups("\textbf{Inflation}", pattern(1 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cline{@span})) ///
    mtitles("$t$" "$t+1$" "$t+2$" "$t+3$" "$t+4$") ///
    gaps note("Standard errors in parenthesis clustered by country and year.") type replace

* Model 2 (controlling for global GPR)
esttab m2_0 m2_1 m2_2 m2_3 m2_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type 

* Model 3 (advanced economies)
esttab m3_0 m3_1 m3_2 m3_3 m3_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type 

* Model 4 (emerging markets)
esttab m4_0 m4_1 m4_2 m4_3 m4_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type 

* Model 5 (post-1950)
esttab m5_0 m5_1 m5_2 m5_3 m5_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type 

* Model 6 (quantile q25)
esttab m6_0 m6_1 m6_2 m6_3 m6_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type 

* Model 7 (quantile q50)
esttab m7_0 m7_1 m7_2 m7_3 m7_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type 

* Model 8 (quantile q75)
esttab m8_0 m8_1 m8_2 m8_3 m8_4 ///
    using output/table2.txt, ///
    keep(cgpr*) nostar nocons label se nor2 depvars noobs b(2) append ///
    nomtitles nonumbers gaps type ///
    note("Standard errors in parenthesis clustered by country and year.")
