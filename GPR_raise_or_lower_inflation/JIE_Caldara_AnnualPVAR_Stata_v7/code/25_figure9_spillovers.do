version 18.0

capture log close _f9
log using "$JIE_LOG/25_figure9_spillovers.log", replace text ///
    name(_f9)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

* ----------------------------------------------------------------------
* Rebuild foreign GPR as the leave-one-out average of domestic GPR
* ----------------------------------------------------------------------
capture confirm variable gpr_foreign_old
if _rc {
    capture drop gpr_foreign_old
    clonevar gpr_foreign_old = gpr_foreign
}

capture drop __sum_gpr_f9
capture drop __n_gpr_f9
capture drop gpr_foreign

bys year: egen __sum_gpr_f9 = total(gpr_country)
bys year: egen __n_gpr_f9   = count(gpr_country)

gen gpr_foreign = .
replace gpr_foreign = ///
    (__sum_gpr_f9 - gpr_country) / (__n_gpr_f9 - 1) ///
    if !missing(gpr_country) & __n_gpr_f9 > 1

drop __sum_gpr_f9 __n_gpr_f9

summ gpr_foreign gpr_foreign_old

* ----------------------------------------------------------------------
* Figure 9 variables
* ----------------------------------------------------------------------
local yraw ///
    gpr_country ///
    gpr_foreign ///
    inflation_ppt ///
    gdp_pct

egen __rowmiss_f9 = rowmiss(`yraw')
gen byte sample_f9 = (__rowmiss_f9 == 0)
drop __rowmiss_f9

count if sample_f9
display as text ///
    "Figure 9 raw complete-case observations: " r(N)

* ----------------------------------------------------------------------
* Pooled estimator: country-demeaned system
* ----------------------------------------------------------------------
sort country_id year

foreach v of local yraw {
    by country_id: egen mean_`v'_f9 = ///
        mean(cond(sample_f9, `v', .))
    gen dm_`v'_f9 = ///
        cond(sample_f9, `v' - mean_`v'_f9, .)
}

local ydm
foreach v of local yraw {
    local ydm `ydm' dm_`v'_f9
}

* ----------------------------------------------------------------------
* Figure 9 is unnormalized:
* shock_idx = 2  -> foreign GPR shock
* scale_idx = 0  -> no normalization
* ----------------------------------------------------------------------
mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f9", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, ///
    2, 0, ///
    "F9P_Q05", "F9P_Q50", "F9P_Q95", ///
    "F9P_MEAN", "F9P_VAR", "F9P_Neff" ///
)

display as text "Figure 9 lag-valid pooled rows: " ///
    %9.0g scalar(F9P_Neff)

* ----------------------------------------------------------------------
* Country-by-country inclusion rule
* ----------------------------------------------------------------------
bys country_id: egen T_f9 = total(sample_f9)
egen tag_country = tag(country_id)

display as text ///
    "Figure 9 countries retained by the " ///
    "$JIE_MINOBS-observation rule:"
levelsof country if tag_country & T_f9 >= $JIE_MINOBS, ///
    local(keep_f9)
local nkeep_f9 : word count `keep_f9'
display as text "Figure 9 included countries: `nkeep_f9'"

display as text ///
    "Figure 9 countries excluded by the " ///
    "$JIE_MINOBS-observation rule:"
levelsof country if tag_country & T_f9 < $JIE_MINOBS, ///
    local(drop_f9)
local ndrop_f9 : word count `drop_f9'
display as text "Figure 9 excluded countries: `ndrop_f9'"

mata: jie_bvar_units_aggregate( ///
    "`yraw'", "country_id", "year", "sample_f9", ///
    $JIE_MINOBS, $JIE_P, $JIE_H, $JIE_NDRAWS, ///
    2, 0, ///
    "F9_IVW", "F9_EW", "F9_B05", "F9_B95", ///
    "F9_Ncountry" ///
)

display as text ///
    "Figure 9 countries used in unit-by-unit aggregation: " ///
    %9.0g scalar(F9_Ncountry)

* ----------------------------------------------------------------------
* Name matrices
* ----------------------------------------------------------------------
local cnP50
local cnIVW
local cnEW
local cnB05
local cnB95

foreach v of local yraw {
    local cnP50 `cnP50' pooled_q50_`v'
    local cnIVW `cnIVW' ivw_`v'
    local cnEW  `cnEW'  ew_`v'
    local cnB05 `cnB05' band_q05_`v'
    local cnB95 `cnB95' band_q95_`v'
}

matrix colnames F9P_Q50 = `cnP50'
matrix colnames F9_IVW  = `cnIVW'
matrix colnames F9_EW   = `cnEW'
matrix colnames F9_B05  = `cnB05'
matrix colnames F9_B95  = `cnB95'

* ----------------------------------------------------------------------
* Put IRFs in a plotting dataset
* ----------------------------------------------------------------------
preserve
clear
set obs `= $JIE_H + 1'
gen horizon = _n - 1

svmat double F9P_Q50, names(col)
svmat double F9_IVW,  names(col)
svmat double F9_EW,   names(col)
svmat double F9_B05,  names(col)
svmat double F9_B95,  names(col)

* GDP panel in percent units, as in the replication figure
replace pooled_q50_gdp_pct = 100 * pooled_q50_gdp_pct
replace ivw_gdp_pct        = 100 * ivw_gdp_pct
replace ew_gdp_pct         = 100 * ew_gdp_pct
replace band_q05_gdp_pct   = 100 * band_q05_gdp_pct
replace band_q95_gdp_pct   = 100 * band_q95_gdp_pct

save "$JIE_DER/fig9_irf.dta", replace
export delimited using "$JIE_DER/fig9_irf.csv", replace

list horizon ///
    pooled_q50_gpr_foreign ///
    ivw_gpr_foreign ///
    ew_gpr_foreign ///
    if horizon <= 10, noobs sep(0)

* ----------------------------------------------------------------------
* Plotting
* ----------------------------------------------------------------------
local bandcol "pink"
local pcol    "blue"
local ivwcol  "red"
local ewcol   "forest_green"

local ylab_gpr_country ///
    "-.05 0 .05 .10 .15"

local ylab_gpr_foreign ///
    "0 .1 .2 .3 .4"

local ylab_inflation ///
    "-.5 0 .5 1 1.5"

* Explicit labels for GDP to avoid dropped negative values
local ylab_gdp ///
    "-1.5 -1 -.5 0 .5 "

twoway ///
    rarea band_q05_gpr_country band_q95_gpr_country ///
        horizon, color(`bandcol'%30) lcolor(`bandcol'%0) || ///
    line ivw_gpr_country horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_gpr_country horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_gpr_country horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("GPR Country", size(medium)) ///
    yline(0, lcolor(gs10)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    ylabel(`ylab_gpr_country', ///
        format(%4.2f) angle(horizontal) ///
        labsize(vsmall) nogrid) ///
    yscale(range(-0.06 0.165)) ///
    legend(order(2 "Variance Weighted" ///
                 3 "Equally Weighted" ///
                 4 "Pooled / Baseline") ///
           rows(3) size(vsmall) pos(2) ring(0) ///
           region(lcolor(black) fcolor(white))) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(medium)) ///
    name(gr9_gpr_country, replace)

twoway ///
    rarea band_q05_gpr_foreign band_q95_gpr_foreign ///
        horizon, color(`bandcol'%30) lcolor(`bandcol'%0) || ///
    line ivw_gpr_foreign horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_gpr_foreign horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_gpr_foreign horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("GPR Foreign", size(medium)) ///
    yline(0, lcolor(gs10)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    ylabel(`ylab_gpr_foreign', ///
        format(%4.1f) angle(horizontal) ///
        labsize(small) nogrid) ///
    yscale(range(-0.02 0.46)) ///
    legend(off) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(medium)) ///
    name(gr9_gpr_foreign, replace)

twoway ///
    rarea band_q05_inflation_ppt band_q95_inflation_ppt ///
        horizon, color(`bandcol'%30) lcolor(`bandcol'%0) || ///
    line ivw_inflation_ppt horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_inflation_ppt horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_inflation_ppt horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("Inflation (ppt)", size(medium)) ///
    yline(0, lcolor(gs10)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    ylabel(`ylab_inflation', ///
        format(%4.1f) angle(horizontal) ///
        labsize(small) nogrid) ///
    yscale(range(-0.5 1.6)) ///
    legend(off) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(medium)) ///
    name(gr9_inflation_ppt, replace)

twoway ///
    rarea band_q05_gdp_pct band_q95_gdp_pct ///
        horizon, color(`bandcol'%30) lcolor(`bandcol'%0) || ///
    line ivw_gdp_pct horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_gdp_pct horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_gdp_pct horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("GDP (%)", size(medium)) ///
    yline(0, lcolor(gs10)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    ylabel(-1.5(.5).5, ///
        format(%3.1f) angle(horizontal) ///
        labsize(small) nogrid) ///
    yscale(range(-1.5 0.5) noextend) ///
    legend(off) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(zero)) ///
    name(gr9_gdp_pct, replace)

graph combine ///
    gr9_gpr_country ///
    gr9_gpr_foreign ///
    gr9_inflation_ppt ///
    gr9_gdp_pct, ///
    cols(2) ///
    imargin(3 3 3 3) ///
    graphregion(color(white) margin(4 4 4 4)) ///
    name(fig9_combined, replace)

graph save "$JIE_FIG/figure9_spillovers.gph", replace
graph export "$JIE_FIG/figure9_spillovers.png", ///
    width(2400) replace

restore

drop tag_country T_f9

log close _f9