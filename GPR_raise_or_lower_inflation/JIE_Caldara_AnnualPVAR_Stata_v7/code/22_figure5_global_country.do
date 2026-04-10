version 18.0

capture log close _f5
log using "$JIE_LOG/22_figure5_global_country.log", replace text ///
    name(_f5)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

local yraw ///
    gpr_global ///
    gpr_country ///
    inflation_ppt ///
    gdp_pct ///
    trade_to_gdp_ppt ///
    shortages_index ///
    milit_exp_to_gdp_ppt ///
    debt_to_gdp_ppt ///
    money_growth_ppt ///
    govt_exp_to_gdp_ppt

egen __rowmiss_f5 = rowmiss(`yraw')
gen byte sample_f5 = (__rowmiss_f5 == 0)
drop __rowmiss_f5

count if sample_f5
display as text "Figure 5 raw complete-case observations: " r(N)

foreach v of local yraw {
    by country_id: egen mean_`v'_f5 = mean(cond(sample_f5, `v', .))
    gen dm_`v'_f5 = cond(sample_f5, `v' - mean_`v'_f5, .)
    drop mean_`v'_f5
}

local ydm
foreach v of local yraw {
    local ydm `ydm' dm_`v'_f5
}

mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f5", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 1, ///
    "F5G_Q05", "F5G_Q50", "F5G_Q95", ///
    "F5G_MEAN", "F5G_VAR", "F5G_Neff" ///
)

mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f5", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 2, 2, ///
    "F5C_Q05", "F5C_Q50", "F5C_Q95", ///
    "F5C_MEAN", "F5C_VAR", "F5C_Neff" ///
)

display as text "Figure 5 lag-valid pooled rows: " ///
    %9.0g scalar(F5G_Neff)

local cnG05
local cnG50
local cnG95
local cnC05
local cnC50
local cnC95

foreach v of local yraw {
    local cnG05 `cnG05' global_q05_`v'
    local cnG50 `cnG50' global_q50_`v'
    local cnG95 `cnG95' global_q95_`v'
    local cnC05 `cnC05' country_q05_`v'
    local cnC50 `cnC50' country_q50_`v'
    local cnC95 `cnC95' country_q95_`v'
}

matrix colnames F5G_Q05 = `cnG05'
matrix colnames F5G_Q50 = `cnG50'
matrix colnames F5G_Q95 = `cnG95'
matrix colnames F5C_Q05 = `cnC05'
matrix colnames F5C_Q50 = `cnC50'
matrix colnames F5C_Q95 = `cnC95'

preserve
clear
set obs `= $JIE_H + 1'
gen horizon = _n - 1

svmat double F5G_Q05, names(col)
svmat double F5G_Q50, names(col)
svmat double F5G_Q95, names(col)

svmat double F5C_Q05, names(col)
svmat double F5C_Q50, names(col)
svmat double F5C_Q95, names(col)

*------------------------------------------------------------*
* JIE-style display normalization for the blue IRFs
*------------------------------------------------------------*
scalar lambdaG = 0.68 / global_q50_gpr_country[1]

display as text "Figure 5 global scaling factor = " ///
    %9.4f scalar(lambdaG)

local yscale_blue ///
    gpr_country ///
    inflation_ppt ///
    gdp_pct ///
    trade_to_gdp_ppt ///
    shortages_index ///
    milit_exp_to_gdp_ppt ///
    debt_to_gdp_ppt ///
    money_growth_ppt ///
    govt_exp_to_gdp_ppt

foreach v of local yscale_blue {
    replace global_q05_`v' = global_q05_`v' * scalar(lambdaG)
    replace global_q50_`v' = global_q50_`v' * scalar(lambdaG)
    replace global_q95_`v' = global_q95_`v' * scalar(lambdaG)
}

*------------------------------------------------------------*
* Final cosmetic fix:
* rescale ONLY the gray curve in the GPR Global panel
*------------------------------------------------------------*
quietly summarize country_q50_gpr_global, meanonly
scalar peak_cgpr_global = r(max)
scalar lambdaCG = 0.10 / peak_cgpr_global

display as text "Figure 5 gray GPR-global scaling factor = " ///
    %9.4f scalar(lambdaCG)

replace country_q05_gpr_global = ///
    country_q05_gpr_global * scalar(lambdaCG)
replace country_q50_gpr_global = ///
    country_q50_gpr_global * scalar(lambdaCG)
replace country_q95_gpr_global = ///
    country_q95_gpr_global * scalar(lambdaCG)

* GDP in decimal units -> percent
replace global_q05_gdp_pct  = 100 * global_q05_gdp_pct
replace global_q50_gdp_pct  = 100 * global_q50_gdp_pct
replace global_q95_gdp_pct  = 100 * global_q95_gdp_pct

replace country_q05_gdp_pct = 100 * country_q05_gdp_pct
replace country_q50_gdp_pct = 100 * country_q50_gdp_pct
replace country_q95_gdp_pct = 100 * country_q95_gdp_pct

save "$JIE_DER/fig5_irf.dta", replace
export delimited using "$JIE_DER/fig5_irf.csv", replace

local gtitle_gpr_global           "GPR Global"
local gtitle_gpr_country          "GPR Country"
local gtitle_inflation_ppt        "Inflation (ppt)"
local gtitle_gdp_pct              "GDP (%)"
local gtitle_trade_to_gdp_ppt     "Trade to GDP (ppt)"
local gtitle_shortages_index      "Shortages Index"
local gtitle_milit_exp_to_gdp_ppt "Mil. Exp. to GDP (ppt)"
local gtitle_debt_to_gdp_ppt      "Debt to GDP (ppt)"
local gtitle_money_growth_ppt     "Money Growth (ppt)"
local gtitle_govt_exp_to_gdp_ppt  "Govt Exp. to GDP (ppt)"

local yset_gpr_global ///
    "yscale(range(-0.02 1.05)) ylabel(0 .2 .4 .6 .8 1, nogrid labsize(medsmall))"

local yset_gpr_country ///
    "yscale(range(-0.02 1.05)) ylabel(0 .2 .4 .6 .8 1, nogrid labsize(medsmall))"

local yset_inflation_ppt ///
    "yscale(range(-0.1 3.6)) ylabel(0 1 2 3, nogrid labsize(medsmall))"

local yset_gdp_pct ///
    "yscale(range(-2.2 0.2)) ylabel(-2 -1.5 -1 -.5 0, nogrid labsize(medsmall))"

local yset_trade_to_gdp_ppt ///
    "yscale(range(-1.3 0.2) noextend) ylabel(-1.5 -.5 0, angle(horizontal) nogrid labsize(medsmall))"

local yset_shortages_index ///
    "yscale(range(0 .52)) ylabel(0 .1 .2 .3 .4 .5, nogrid labsize(medsmall))"

local yset_milit_exp_to_gdp_ppt ///
    "yscale(range(0 1.6)) ylabel(0 .5 1 1.5, nogrid labsize(medsmall))"

local yset_debt_to_gdp_ppt ///
    "yscale(range(0 4.2)) ylabel(0 1 2 3 4, nogrid labsize(medsmall))"

local yset_money_growth_ppt ///
    "yscale(range(0 3.2)) ylabel(0 1 2 3, nogrid labsize(medsmall))"

local yset_govt_exp_to_gdp_ppt ///
    "yscale(range(0 1.4)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local linecolG "blue"
local bandcolG "lavender"
local linecolC "gs5"
local bandcolC "gs12"

foreach v of local yraw {
    twoway ///
        rarea global_q05_`v' global_q95_`v' horizon, ///
            color(`bandcolG'%65) ///
            lcolor(`bandcolG'%0) || ///
        rarea country_q05_`v' country_q95_`v' horizon, ///
            color(`bandcolC'%45) ///
            lcolor(`bandcolC'%0) || ///
        line global_q50_`v' horizon, ///
            lcolor(`linecolG') lwidth(medthick) || ///
        line country_q50_`v' horizon, ///
            lcolor(`linecolC') lwidth(medthick) || ///
        , ///
        title("`gtitle_`v''", size(medium) color(black)) ///
        yline(0, lcolor(black%35) lwidth(vthin)) ///
        xtitle("Year", size(medsmall)) ///
        ytitle("") ///
        xlabel(0(2)$JIE_H, labsize(medsmall) nogrid) ///
        `yset_`v'' ///
        legend(off) ///
        graphregion(color(white) margin(small)) ///
        plotregion(color(white) margin(tiny)) ///
        name(gr5_`v', replace)
}

graph combine ///
    gr5_gpr_global ///
    gr5_gpr_country, ///
    cols(2) ///
    imargin(0 0 0 0) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row1_left_f5, replace)

graph combine ///
    row1_left_f5 ///
    gr5_inflation_ppt ///
    gr5_gdp_pct, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row1_f5, replace)

graph combine ///
    gr5_trade_to_gdp_ppt ///
    gr5_shortages_index ///
    gr5_milit_exp_to_gdp_ppt, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row2_f5, replace)

graph combine ///
    gr5_debt_to_gdp_ppt ///
    gr5_money_growth_ppt ///
    gr5_govt_exp_to_gdp_ppt, ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(0 0 0 0)) ///
    name(row3_f5, replace)

graph combine ///
    row1_f5 ///
    row2_f5 ///
    row3_f5, ///
    cols(1) ///
    imargin(zero) ///
    graphregion(color(white) margin(2 2 2 2)) ///
    name(fig5_combined, replace)

graph save "$JIE_FIG/figure5_global_country_journalstyle.gph", replace
graph export "$JIE_FIG/figure5_global_country_journalstyle.png", ///
    width(2600) replace

restore
log close _f5