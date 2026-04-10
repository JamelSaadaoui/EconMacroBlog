version 18.0

capture log close _f6
log using "$JIE_LOG/23_figure6_narrative.log", replace text ///
    name(_f6)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

* ----------------------------------------------------------------------
* Baseline specification
* ----------------------------------------------------------------------
local yraw_base ///
    gpr_country ///
    inflation_ppt ///
    gdp_pct ///
    trade_to_gdp_ppt ///
    shortages_index ///
    milit_exp_to_gdp_ppt ///
    debt_to_gdp_ppt ///
    money_growth_ppt ///
    govt_exp_to_gdp_ppt

egen __rowmiss_f6b = rowmiss(`yraw_base')
gen byte sample_f6_base = (__rowmiss_f6b == 0)
drop __rowmiss_f6b

foreach v of local yraw_base {
    by country_id: egen mean_`v'_f6b = ///
        mean(cond(sample_f6_base, `v', .))
    gen dm_`v'_f6b = ///
        cond(sample_f6_base, `v' - mean_`v'_f6b, .)
}

local ydm_base
foreach v of local yraw_base {
    local ydm_base `ydm_base' dm_`v'_f6b
}

mata: jie_bvar_pooled_summary( ///
    "`ydm_base'", "country_id", "year", "sample_f6_base", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 1, ///
    "F6B_Q05", "F6B_Q50", "F6B_Q95", ///
    "F6B_MEAN", "F6B_VAR", "F6B_Neff" ///
)

* ----------------------------------------------------------------------
* Narrative specification
* ----------------------------------------------------------------------
local yraw_narr ///
    gpr_narrative ///
    gpr_country ///
    inflation_ppt ///
    gdp_pct ///
    trade_to_gdp_ppt ///
    shortages_index ///
    milit_exp_to_gdp_ppt ///
    debt_to_gdp_ppt ///
    money_growth_ppt ///
    govt_exp_to_gdp_ppt

egen __rowmiss_f6n = rowmiss(`yraw_narr')
gen byte sample_f6_narr = (__rowmiss_f6n == 0)
drop __rowmiss_f6n

foreach v of local yraw_narr {
    by country_id: egen mean_`v'_f6n = ///
        mean(cond(sample_f6_narr, `v', .))
    gen dm_`v'_f6n = ///
        cond(sample_f6_narr, `v' - mean_`v'_f6n, .)
}

local ydm_narr
foreach v of local yraw_narr {
    local ydm_narr `ydm_narr' dm_`v'_f6n
}

mata: jie_bvar_pooled_summary( ///
    "`ydm_narr'", "country_id", "year", "sample_f6_narr", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 2, ///
    "F6N_Q05", "F6N_Q50", "F6N_Q95", ///
    "F6N_MEAN", "F6N_VAR", "F6N_Neff" ///
)

display as text "Figure 6 baseline lag-valid pooled rows: " ///
    %9.0g scalar(F6B_Neff)

display as text "Figure 6 narrative lag-valid pooled rows: " ///
    %9.0g scalar(F6N_Neff)

* Keep narrative responses for cols 2..10 so displayed variables match Fig. 3
matrix F6N_Q05P = F6N_Q05[1..rowsof(F6N_Q05), 2..colsof(F6N_Q05)]
matrix F6N_Q50P = F6N_Q50[1..rowsof(F6N_Q50), 2..colsof(F6N_Q50)]
matrix F6N_Q95P = F6N_Q95[1..rowsof(F6N_Q95), 2..colsof(F6N_Q95)]

local cnB05
local cnB50
local cnB95
local cnN05
local cnN50
local cnN95

foreach v of local yraw_base {
    local cnB05 `cnB05' base_q05_`v'
    local cnB50 `cnB50' base_q50_`v'
    local cnB95 `cnB95' base_q95_`v'
    local cnN05 `cnN05' narr_q05_`v'
    local cnN50 `cnN50' narr_q50_`v'
    local cnN95 `cnN95' narr_q95_`v'
}

matrix colnames F6B_Q05  = `cnB05'
matrix colnames F6B_Q50  = `cnB50'
matrix colnames F6B_Q95  = `cnB95'
matrix colnames F6N_Q05P = `cnN05'
matrix colnames F6N_Q50P = `cnN50'
matrix colnames F6N_Q95P = `cnN95'

preserve
clear
set obs `= $JIE_H + 1'
gen horizon = _n - 1

svmat double F6B_Q05,  names(col)
svmat double F6B_Q50,  names(col)
svmat double F6B_Q95,  names(col)
svmat double F6N_Q05P, names(col)
svmat double F6N_Q50P, names(col)
svmat double F6N_Q95P, names(col)

* Match Figure 3 scaling for GDP
replace base_q05_gdp_pct = 100 * base_q05_gdp_pct
replace base_q50_gdp_pct = 100 * base_q50_gdp_pct
replace base_q95_gdp_pct = 100 * base_q95_gdp_pct

replace narr_q05_gdp_pct = 100 * narr_q05_gdp_pct
replace narr_q50_gdp_pct = 100 * narr_q50_gdp_pct
replace narr_q95_gdp_pct = 100 * narr_q95_gdp_pct

save "$JIE_DER/fig6_irf.dta", replace
export delimited using "$JIE_DER/fig6_irf.csv", replace

local gtitle_gpr_country          "GPR Country"
local gtitle_inflation_ppt        "Inflation (ppt)"
local gtitle_gdp_pct              "GDP (%)"
local gtitle_trade_to_gdp_ppt     "Trade to GDP (ppt)"
local gtitle_shortages_index      "Shortages Index"
local gtitle_milit_exp_to_gdp_ppt "Mil. Exp. to GDP (ppt)"
local gtitle_debt_to_gdp_ppt      "Debt to GDP (ppt)"
local gtitle_money_growth_ppt     "Money Growth (ppt)"
local gtitle_govt_exp_to_gdp_ppt  "Govt Exp to GDP (ppt)"

* Use Figure 3 journal-style axis settings
local yset_gpr_country ///
    "yscale(range(-0.02 1.05)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local yset_inflation_ppt ///
    "yscale(range(0 3)) ylabel(0 1 2 2.5, nogrid labsize(medsmall))"

local yset_gdp_pct ///
    "yscale(range(-2.3 0.1)) ylabel(-2.5 -2 -1.5 -1 -.5 0, nogrid labsize(medsmall))"

local yset_trade_to_gdp_ppt ///
    "yscale(range(-1.15 0.05) noextend) ylabel(-2 -1.5 -1 -.5 0, angle(horizontal) nogrid labsize(medsmall))"

local yset_shortages_index ///
    "yscale(range(0 .5)) ylabel(0 .2 .4 .6, nogrid labsize(medsmall))"

local yset_milit_exp_to_gdp_ppt ///
    "yscale(range(0 1.4)) ylabel(0 .5 1 1.5, nogrid labsize(medsmall))"

local yset_debt_to_gdp_ppt ///
    "yscale(range(0 4.2)) ylabel(0 1 2 3 4 5, nogrid labsize(medsmall))"

local yset_money_growth_ppt ///
    "yscale(range(0 2.2)) ylabel(0 .5 1 1.5 2, nogrid labsize(medsmall))"

local yset_govt_exp_to_gdp_ppt ///
    "yscale(range(0 1.4)) ylabel(0 .5 1 1.5 2, nogrid labsize(medsmall))"

local base_line  "blue"
local base_band  "lavender"
local narr_line  "gs5"
local narr_band  "gs12"

local graphs
local i = 0

foreach v of local yraw_base {
    local ++i

    if `i' == 1 {
        local legopt ///
            legend(off)
    }
    else {
        local legopt legend(off)
    }

    twoway ///
        rarea base_q05_`v' base_q95_`v' horizon, ///
            color(`base_band'%65) lcolor(`base_band'%0) || ///
        rarea narr_q05_`v' narr_q95_`v' horizon, ///
            color(`narr_band'%55) lcolor(`narr_band'%0) || ///
        line base_q50_`v' horizon, ///
            lcolor(`base_line') lwidth(medthick) || ///
        line narr_q50_`v' horizon, ///
            lcolor(`narr_line') lwidth(medthick) || ///
        , ///
        title("`gtitle_`v''", size(medium) color(black)) ///
        yline(0, lcolor(black%35) lwidth(vthin)) ///
        xtitle("Year", size(medsmall)) ///
        ytitle("") ///
        xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
        `yset_`v'' ///
        `legopt' ///
        graphregion(color(white) margin(small)) ///
        plotregion(color(white) margin(tiny)) ///
        name(gr6_`v', replace)

    local graphs `graphs' gr6_`v'
}

graph combine `graphs', ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(2 2 2 2)) ///
    name(fig6_combined, replace)

graph save "$JIE_FIG/figure6_narrative_journalstyle.gph", replace
graph export "$JIE_FIG/figure6_narrative_journalstyle.png", ///
    width(2400) replace

restore
log close _f6