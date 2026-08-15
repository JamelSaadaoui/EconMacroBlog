/****************************************************************************
 xtthreshold_asean_blog.do

 Illustrative re-estimation of Ho and Saadaoui (2022) with xtthreshold.

 Global macros are used for settings and variable lists outside loops.

 HOW TO RUN
 ----------
 1. Unzip the replication package.
 2. Copy this do-file to the root of the unzipped folder.
 3. The root must contain data/, figures/, logs/, and results/.
 4. Make the root folder Stata's current working directory.
 5. Run:

        do xtthreshold_asean_blog.do

 IMPORTANT ECONOMETRIC NOTE
 --------------------------
 xtthreshold implements a static panel threshold model with interactive fixed
 effects. It is therefore an illustration and a sensitivity exercise, not an
 exact replication of the dynamic GMM threshold model in Ho and Saadaoui
 (2022). In particular, the lagged dependent variable is deliberately omitted.
 The fixed-T theory relies on a large cross-sectional dimension. The ASEAN
 dataset contains only seven countries, so inference must be interpreted with
 caution.

 The main specification mirrors the no-population baseline in endo_thresh.do.
 GDP-per-capita growth is explained by credit-to-GDP, investment, government
 expenditure, terms of trade, openness, and inflation. Only the coefficient on
 credit-to-GDP changes across regimes.
****************************************************************************/

version 18.0
clear all
cls
set more off
set linesize 80
set level 95

/*
 A note on _rc:

 After a command run under capture, Stata stores its return code in _rc.
 A value of 0 means that the command succeeded. Any nonzero value means that
 it failed. Because the next command can overwrite _rc, save it immediately
 in a named global when it will be used later. For example:

     capture noisily estat graph lr
     global XTTH_RC_LR = _rc
*/

*----------------------------------------------------------------------------
**# 0. Verify the replication-package root
*----------------------------------------------------------------------------

capture confirm file "data/data_asean_final.dta"
if _rc != 0 {
    display as error "The file data/data_asean_final.dta was not found."
    display as error "Run this do-file from the unzipped package root."
    display as text "Current working directory: `c(pwd)'"
    error 601
}

foreach folder in logs results figures {
    capture mkdir "`folder'"
}

capture log close _all
log using "logs/xtthreshold_asean_blog.log", ///
    text replace name(xtthlog)

*----------------------------------------------------------------------------
**# 1. Install or update the required packages
*----------------------------------------------------------------------------

* Set this global to 0 after the first successful run to skip update checks.
global XTTH_UPDATE_PACKAGES 0

if ${XTTH_UPDATE_PACKAGES} == 1 {
    capture noisily ssc install moremata, replace
    capture noisily net install xtthreshold, ///
        from("https://janditzen.github.io/xtthreshold/") replace
    capture noisily net install xtdcce2, ///
        from("https://janditzen.github.io/xtdcce2/") replace
}

capture findfile moremata.hlp
if _rc != 0 {
    display as error "moremata is required but is not installed."
    capture log close xtthlog
    error 499
}

foreach command in xtthreshold xtdcce2 {
    capture which `command'
    if _rc != 0 {
        display as error "The required command `command' is not installed."
        capture log close xtthlog
        error 499
    }
}

*----------------------------------------------------------------------------
**# 2. Load and declare the ASEAN panel
*----------------------------------------------------------------------------

use "data/data_asean_final.dta", clear

encode cn, generate(country_id)
order country_id cn code year, first
isid country_id year
xtset country_id year

label variable country_id "Country"
label variable year "Year"
label variable gdpgpc "Annual growth rate of GDP per capita"
label variable creditgdp "Credit-to-GDP ratio"
label variable inv "Annual percentage change in investment"
label variable gov ///
    "Annual percentage change in government expenditure"
label variable tot "Terms of trade"
label variable open "Openness ratio"
label variable inflation "Annual percentage change of the CPI"

quietly egen byte __panel_tag = tag(country_id)
quietly count if __panel_tag
global XTTH_N = r(N)
drop __panel_tag

quietly summarize year, meanonly
global XTTH_FIRST_YEAR = r(min)
global XTTH_LAST_YEAR = r(max)
global XTTH_T = ${XTTH_LAST_YEAR} - ${XTTH_FIRST_YEAR} + 1

noi display as result "Panel dimensions:"
noi display as result "  N = ${XTTH_N}"
noi display as result "  T = ${XTTH_T}"
noi display as result ///
    "  Years = ${XTTH_FIRST_YEAR}-${XTTH_LAST_YEAR}"
noi display as text "This is an empirical illustration of xtthreshold."
noi display as error "Caution: fixed-T inference assumes that N is large."
noi display as error "Here, N = ${XTTH_N}; interpret inference cautiously."

xtdescribe
summarize gdpgpc creditgdp inv gov tot open inflation

*----------------------------------------------------------------------------
**# 3. Define the interactive-fixed-effects threshold model
*----------------------------------------------------------------------------

global XTTH_Y gdpgpc
global XTTH_Z creditgdp
global XTTH_CONTROLS inv gov tot open inflation
global XTTH_CSA ${XTTH_Z}
global XTTH_GRID 90

/*
 Syntax reminder:

   xtthreshold depvar variables_with_regime_dependent_slopes |
               variables_with_constant_slopes,
               threshold(threshold_variable)

 creditgdp is placed before | because its coefficient may differ below and
 above the estimated threshold. The remaining controls are placed after |
 because their coefficients are constant across the two regimes.

 Following the fixed-T threshold theory, the cross-sectional averages contain
 the regressors but not the dependent variable.
*/

xtthreshold ${XTTH_Y} ${XTTH_Z} | ${XTTH_CONTROLS}, ///
    threshold(${XTTH_Z}) ///
    csa(${XTTH_CSA}) ///
    grid(${XTTH_GRID})

estimates store XTTHRESHOLD_SEARCH
capture estimates save ///
    "results/xtthreshold_search.ster", replace

ereturn list

*----------------------------------------------------------------------------
**# 4. Plot the likelihood-ratio profile
*----------------------------------------------------------------------------

* Keep this directly after the first xtthreshold estimation. In version 0.1,
* estat graph lr refers to the Mata object created by that estimation.
capture noisily estat graph lr
global XTTH_RC_LR = _rc

if ${XTTH_RC_LR} == 0 {
    capture graph rename Graph xtthreshold_lr, replace
    capture noisily graph export ///
        "figures/xtthreshold_lr.png", width(2400) replace
    capture noisily graph export ///
        "figures/xtthreshold_lr.pdf", replace
    capture noisily graph export ///
        "figures/xtthreshold_lr.svg", replace
}
else {
    display as error "The LR graph could not be produced."
    display as error "Inspect the log for the returned error."
}

*----------------------------------------------------------------------------
* 5. Split credit-to-GDP at the estimated threshold
*----------------------------------------------------------------------------

capture noisily estat split
global XTTH_RC_SPLIT = _rc

if ${XTTH_RC_SPLIT} != 0 {
    display as error "estat split failed."
    display as error "The final CCE model cannot be estimated."
    capture log close xtthlog
    error ${XTTH_RC_SPLIT}
}

capture confirm variable creditgdp_0
if _rc != 0 {
    display as error "estat split did not create creditgdp_0."
    capture log close xtthlog
    error 111
}

capture confirm variable creditgdp_1
if _rc != 0 {
    display as error "estat split did not create creditgdp_1."
    capture log close xtthlog
    error 111
}

label variable creditgdp_0 ///
    "Credit-to-GDP below the estimated threshold"
label variable creditgdp_1 ///
    "Credit-to-GDP above the estimated threshold"

generate byte high_credit_regime = ///
    !missing(creditgdp_1) & creditgdp_1 != 0 ///
    if !missing(creditgdp)

label define high_credit_lbl ///
    0 "Below threshold" ///
    1 "Above threshold"
label values high_credit_regime high_credit_lbl
label variable high_credit_regime "Estimated credit regime"

noi tabulate high_credit_regime
noi tabulate country_id high_credit_regime, row

*----------------------------------------------------------------------------
**# 6. Estimate the final pooled CCE threshold regression
*----------------------------------------------------------------------------

/*
 The xtthreshold documentation illustrates the post-threshold regression with
 xtdcce2. All structural slopes are pooled here. The constant and coefficients
 on the cross-sectional averages remain country-specific. This matches the
 common-slope structure used during the threshold search.

 pooledvce(wpn) requests the fixed-T adjustment available in xtdcce2.
 mgmissing is useful because a country may lie entirely within one regime.
 A split regressor may then be collinear in a country-specific regression.
*/

global XTTH_SPLITVARS creditgdp_0 creditgdp_1
global XTTH_MODELVARS ${XTTH_SPLITVARS} ${XTTH_CONTROLS}

* The package documentation's heterogeneous CCE follow-up is:
*
* xtdcce2 ${XTTH_Y} ${XTTH_MODELVARS}, ///
*     cr(${XTTH_CSA}) mgmissing
*
* The structural slopes are pooled here to follow the common-slope model.

capture noisily xtdcce2 ${XTTH_Y} ${XTTH_MODELVARS}, ///
    cr(${XTTH_Y} ${XTTH_CSA}, cr_lags(0)) ///
    pooled(${XTTH_MODELVARS}) ///
    pooledvce(wpn) ///
    mgmissing
global XTTH_RC_CCEP = _rc

* Use the default pooled VCE if WPN is unavailable or numerically infeasible.
if ${XTTH_RC_CCEP} != 0 {
    display as error "The WPN specification failed."
    display as error "Retrying with xtdcce2's default pooled VCE."

    capture noisily xtdcce2 ${XTTH_Y} ${XTTH_MODELVARS}, ///
        cr(${XTTH_Y} ${XTTH_CSA}, cr_lags(0)) ///
        pooled(${XTTH_MODELVARS}) ///
        mgmissing
    global XTTH_RC_CCEP = _rc
}

if ${XTTH_RC_CCEP} == 0 {
    estimates store CCEP_THRESHOLD
    estimates save ///
        "results/xtthreshold_ccep_estimates.ster", replace

    ereturn list

    * Test whether the credit slopes are identical across regimes.
    capture noisily test creditgdp_0 = creditgdp_1
    capture noisily lincom creditgdp_0 - creditgdp_1

*------------------------------------------------------------------------
**# 7. Plot the two regime-specific credit slopes
*------------------------------------------------------------------------

    capture scalar b_low = _b[creditgdp_0]
    global XTTH_RC_B = _rc

    if ${XTTH_RC_B} == 0 {
        scalar se_low = _se[creditgdp_0]
        scalar b_high = _b[creditgdp_1]
        scalar se_high = _se[creditgdp_1]
        scalar zcrit = invnormal(1 - (1 - c(level) / 100) / 2)

        preserve
            clear
            set obs 2

            generate byte regime = _n
            generate double estimate = .
            generate double se = .

            replace estimate = b_low in 1
            replace estimate = b_high in 2
            replace se = se_low in 1
            replace se = se_high in 2

            generate double ci_low = estimate - zcrit * se
            generate double ci_high = estimate + zcrit * se
            generate str12 estimate_label = ///
                string(estimate, "%9.3f")

            label define regime_lbl ///
                1 "Below estimated threshold" ///
                2 "Above estimated threshold"
            label values regime regime_lbl

            twoway ///
                (rcap ci_low ci_high regime, horizontal) ///
                (scatter regime estimate, ///
                    mlabel(estimate_label) ///
                    mlabposition(12)), ///
                ytitle("") ///
                ylabel(1 2, valuelabel angle(horizontal)) ///
                xtitle("Coefficient on the credit-to-GDP ratio") ///
                xline(0, lpattern(dash)) ///
                title("Bank credit and GDP-per-capita growth") ///
                subtitle( ///
                    "Pooled CCE estimates with `c(level)'% CIs") ///
                note( ///
                    "Threshold: xtthreshold; slopes: xtdcce2.") ///
                legend(off) ///
                name(xtthreshold_credit_slopes, replace)

            capture noisily graph export ///
                "figures/xtthreshold_credit_slopes.png", ///
                width(2400) replace
            capture noisily graph export ///
                "figures/xtthreshold_credit_slopes.pdf", replace
            capture noisily graph export ///
                "figures/xtthreshold_credit_slopes.svg", replace
        restore
    }
    else {
        display as error "The regime coefficients could not be read."
        display as error "No coefficient graph was produced."
    }
}
else {
    display as error "The final pooled CCE regression failed."
    display as error "Inspect the log for details."
}

* Save the data containing the split credit variables for inspection.
save "results/xtthreshold_asean_split.dta", replace

noi display as result "Completed. Main outputs:"
noi display as text "  logs/xtthreshold_asean_blog.log"
noi display as text "  figures/xtthreshold_lr.png"
noi display as text "  figures/xtthreshold_credit_slopes.png"
noi display as text "  results/xtthreshold_asean_split.dta"

capture log close xtthlog
