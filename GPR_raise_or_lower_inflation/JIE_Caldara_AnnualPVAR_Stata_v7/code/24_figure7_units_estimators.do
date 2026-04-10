version 18.0

capture log close _f7
log using "$JIE_LOG/24_figure7_units_estimators.log", replace text ///
    name(_f7)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

local yraw ///
    gpr_country ///
    inflation_ppt ///
    gdp_pct

egen __rowmiss_f7 = rowmiss(`yraw')
gen byte sample_f7 = (__rowmiss_f7 == 0)
drop __rowmiss_f7

count if sample_f7
display as text "Figure 7 raw complete-case observations: " r(N)

foreach v of local yraw {
    by country_id: egen mean_`v'_f7 = mean(cond(sample_f7, `v', .))
    gen dm_`v'_f7 = cond(sample_f7, `v' - mean_`v'_f7, .)
}

local ydm
foreach v of local yraw {
    local ydm `ydm' dm_`v'_f7
}

mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f7", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 1, ///
    "F7P_Q05", "F7P_Q50", "F7P_Q95", ///
    "F7P_MEAN", "F7P_VAR", "F7P_Neff" ///
)

display as text "Figure 7 lag-valid pooled rows: " ///
    %9.0g scalar(F7P_Neff)

bys country_id: egen T_f7 = total(sample_f7)
egen tag_country = tag(country_id)

display as text ///
    "Figure 7 countries retained by the $JIE_MINOBS-observation rule:"
levelsof country if tag_country & T_f7 >= $JIE_MINOBS, local(keep_f7)
local nkeep_f7 : word count `keep_f7'
display as text "Figure 7 included countries: `nkeep_f7'"

display as text ///
    "Figure 7 countries excluded by the $JIE_MINOBS-observation rule:"
levelsof country if tag_country & T_f7 < $JIE_MINOBS, local(drop_f7)
local ndrop_f7 : word count `drop_f7'
display as text "Figure 7 excluded countries: `ndrop_f7'"

mata: jie_bvar_units_aggregate( ///
    "`yraw'", "country_id", "year", "sample_f7", ///
    $JIE_MINOBS, $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 1, ///
    "F7_IVW", "F7_EW", "F7_B05", "F7_B95", "F7_Ncountry" ///
)

display as text "Figure 7 countries used in aggregation: " ///
    %9.0g scalar(F7_Ncountry)

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

matrix colnames F7P_Q50 = `cnP50'
matrix colnames F7_IVW  = `cnIVW'
matrix colnames F7_EW   = `cnEW'
matrix colnames F7_B05  = `cnB05'
matrix colnames F7_B95  = `cnB95'

preserve
clear
set obs `= $JIE_H + 1'
gen horizon = _n - 1

svmat double F7P_Q50, names(col)
svmat double F7_IVW,  names(col)
svmat double F7_EW,   names(col)
svmat double F7_B05,  names(col)
svmat double F7_B95,  names(col)

replace pooled_q50_gdp_pct = 100 * pooled_q50_gdp_pct
replace ivw_gdp_pct        = 100 * ivw_gdp_pct
replace ew_gdp_pct         = 100 * ew_gdp_pct
replace band_q05_gdp_pct   = 100 * band_q05_gdp_pct
replace band_q95_gdp_pct   = 100 * band_q95_gdp_pct

save "$JIE_DER/fig7_irf.dta", replace
export delimited using "$JIE_DER/fig7_irf.csv", replace

local bandcol "pink"
local pcol    "blue"
local ivwcol  "red"
local ewcol   "forest_green"

twoway ///
    rarea band_q05_gpr_country band_q95_gpr_country horizon, ///
        color(`bandcol'%25) lcolor(`bandcol'%0) || ///
    line ivw_gpr_country horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_gpr_country horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_gpr_country horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("GPR Country", size(medium) color(black)) ///
    yline(0, lcolor(black%35) lwidth(vthin)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    yscale(range(-0.08 1.05)) ///
    ylabel(0 .2 .4 .6 .8 1, nogrid labsize(medsmall)) ///
    legend(order(2 "Variance Weighted" ///
                 3 "Equally Weighted" ///
                 4 "Pooled / Baseline") ///
           rows(3) size(small) ring(0) pos(2) ///
           region(lcolor(black) fcolor(white))) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(tiny)) ///
    name(gr7_gpr_country, replace)

twoway ///
    rarea band_q05_inflation_ppt band_q95_inflation_ppt horizon, ///
        color(`bandcol'%25) lcolor(`bandcol'%0) || ///
    line ivw_inflation_ppt horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_inflation_ppt horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_inflation_ppt horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("Inflation (ppt)", size(medium) color(black)) ///
    yline(0, lcolor(black%35) lwidth(vthin)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    yscale(range(-0.7 3.4)) ///
    ylabel(-.5 0 .5 1 1.5 2 2.5 3, ///
        nogrid labsize(medsmall)) ///
    legend(off) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(tiny)) ///
    name(gr7_inflation_ppt, replace)

twoway ///
    rarea band_q05_gdp_pct band_q95_gdp_pct horizon, ///
        color(`bandcol'%25) lcolor(`bandcol'%0) || ///
    line ivw_gdp_pct horizon, ///
        lcolor(`ivwcol') lwidth(medthick) || ///
    line ew_gdp_pct horizon, ///
        lcolor(`ewcol') lwidth(medthick) ///
        lpattern(shortdash) || ///
    line pooled_q50_gdp_pct horizon, ///
        lcolor(`pcol') lwidth(thick) || ///
    , ///
    title("GDP (%)", size(medium) color(black)) ///
    yline(0, lcolor(black%35) lwidth(vthin)) ///
    xtitle("Year", size(medsmall)) ///
    ytitle("") ///
    xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
    yscale(range(-3.6 0.6)) ///
    ylabel(-3 -2 -1 0, nogrid labsize(medsmall)) ///
    legend(off) ///
    graphregion(color(white) margin(small)) ///
    plotregion(color(white) margin(tiny)) ///
    name(gr7_gdp_pct, replace)

graph combine ///
    gr7_gpr_country ///
    gr7_inflation_ppt ///
    gr7_gdp_pct, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(2 2 2 2)) ///
    name(fig7_combined, replace)

graph save "$JIE_FIG/figure7_units_estimators_journalstyle.gph", replace
graph export "$JIE_FIG/figure7_units_estimators_journalstyle.png", ///
    width(2400) replace

restore
drop tag_country T_f7
log close _f7