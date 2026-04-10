version 18.0

capture log close _f3
log using "$JIE_LOG/20_figure3_panel_bvar.log", replace text ///
    name(_f3)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

local yraw ///
    gpr_country ///
    inflation_ppt ///
    gdp_pct ///
    trade_to_gdp_ppt ///
    shortages_index ///
    milit_exp_to_gdp_ppt ///
    debt_to_gdp_ppt ///
    money_growth_ppt ///
    govt_exp_to_gdp_ppt

egen __rowmiss_f3 = rowmiss(`yraw')
gen byte sample_f3 = (__rowmiss_f3 == 0)
drop __rowmiss_f3

count if sample_f3
display as text "Figure 3 raw complete-case observations: " r(N)

qui levelsof country if sample_f3, local(countries_f3)
local ncountry : word count `countries_f3'
display as text "Figure 3 countries: `ncountry'"

foreach v of local yraw {
    by country_id: egen mean_`v'_f3 = mean(cond(sample_f3, `v', .))
    gen dm_`v'_f3 = cond(sample_f3, `v' - mean_`v'_f3, .)
}

local ydm
foreach v of local yraw {
    local ydm `ydm' dm_`v'_f3
}

mata: jie_bvar_pooled_summary( ///
    "`ydm'", "country_id", "year", "sample_f3", ///
    $JIE_P, $JIE_H, $JIE_NDRAWS, 1, 1, ///
    "F3_Q05", "F3_Q50", "F3_Q95", ///
    "F3_MEAN", "F3_VAR", "F3_Neff" ///
)

display as text "Figure 3 lag-valid pooled rows: " ///
    %9.0g scalar(F3_Neff)

local cn05
local cn50
local cn95
foreach v of local yraw {
    local cn05 `cn05' q05_`v'
    local cn50 `cn50' q50_`v'
    local cn95 `cn95' q95_`v'
}

matrix colnames F3_Q05 = `cn05'
matrix colnames F3_Q50 = `cn50'
matrix colnames F3_Q95 = `cn95'

preserve
clear
set obs `= $JIE_H + 1'
gen horizon = _n - 1

svmat double F3_Q05, names(col)
svmat double F3_Q50, names(col)
svmat double F3_Q95, names(col)

replace q05_gdp_pct = 100 * q05_gdp_pct
replace q50_gdp_pct = 100 * q50_gdp_pct
replace q95_gdp_pct = 100 * q95_gdp_pct

save "$JIE_DER/fig3_irf.dta", replace
export delimited using "$JIE_DER/fig3_irf.csv", replace

local gtitle_gpr_country          "GPR Country"
local gtitle_inflation_ppt        "Inflation (ppt)"
local gtitle_gdp_pct              "GDP (%)"
local gtitle_trade_to_gdp_ppt     "Trade to GDP (ppt)"
local gtitle_shortages_index      "Shortages Index"
local gtitle_milit_exp_to_gdp_ppt "Mil. Exp. to GDP (ppt)"
local gtitle_debt_to_gdp_ppt      "Debt to GDP (ppt)"
local gtitle_money_growth_ppt     "Money Growth (ppt)"
local gtitle_govt_exp_to_gdp_ppt  "Govt Exp to GDP (ppt)"

local yset_gpr_country ///
    "yscale(range(-0.02 1.05)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local yset_inflation_ppt ///
    "yscale(range(0 3)) ylabel(0 1 2, nogrid labsize(medsmall))"

local yset_gdp_pct ///
    "yscale(range(-2.3 0.1)) ylabel(-2 -1.5 -1 -.5 0, nogrid labsize(medsmall))"

local yset_trade_to_gdp_ppt ///
    "yscale(range(-1.15 0.05) noextend) ylabel(-1 -.5 0, angle(horizontal) nogrid labsize(medsmall))"

local yset_shortages_index ///
    "yscale(range(0 .5)) ylabel(0 .2 .4, nogrid labsize(medsmall))"

local yset_milit_exp_to_gdp_ppt ///
    "yscale(range(0 1.4)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local yset_debt_to_gdp_ppt ///
    "yscale(range(0 4.2)) ylabel(0 1 2 3 4, nogrid labsize(medsmall))"

local yset_money_growth_ppt ///
    "yscale(range(0 2.2)) ylabel(0 .5 1 1.5 2, nogrid labsize(medsmall))"

local yset_govt_exp_to_gdp_ppt ///
    "yscale(range(0 1.4)) ylabel(0 .5 1, nogrid labsize(medsmall))"

local linecol "blue"
local bandcol "lavender"

local graphs
foreach v of local yraw {
    twoway ///
        rarea q05_`v' q95_`v' horizon, ///
            color(`bandcol'%65) ///
            lcolor(`bandcol'%0) || ///
        line q50_`v' horizon, ///
            lcolor(`linecol') lwidth(medthick) || ///
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
        name(gr3_`v', replace)

    local graphs `graphs' gr3_`v'
}

graph combine `graphs', ///
    cols(3) ///
    imargin(1 1 1 1) ///
    graphregion(color(white) margin(2 2 2 2)) ///
    name(fig3_combined, replace)

graph save "$JIE_FIG/figure3_panel_bvar_journalstyle.gph", replace
graph export "$JIE_FIG/figure3_panel_bvar_journalstyle.png", ///
    width(2400) replace

restore
log close _f3