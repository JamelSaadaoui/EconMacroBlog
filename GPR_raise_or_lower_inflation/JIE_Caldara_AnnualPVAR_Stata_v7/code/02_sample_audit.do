version 18.0

capture log close _audit
log using "$JIE_LOG/02_sample_audit.log", replace text name(_audit)

use "$JIE_DER/annual_panel.dta", clear
sort country_id year
xtset country_id year

local f36  gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt
local f46  gpa_country gpt_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt
local f56  gpr_global gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt
local f66  gpr_narrative gpr_country inflation_ppt gdp_pct trade_to_gdp_ppt shortages_index milit_exp_to_gdp_ppt debt_to_gdp_ppt money_growth_ppt govt_exp_to_gdp_ppt
local f7   gpr_country inflation_ppt gdp_pct
local f9   gpr_country gpr_foreign inflation_ppt gdp_pct

foreach S in f36 f46 f56 f66 f7 f9 {
    egen __rowmiss_`S' = rowmiss(``S'')
    gen byte sample_`S' = (__rowmiss_`S' == 0)
    drop __rowmiss_`S'
    count if sample_`S'
    local N = r(N)
    qui levelsof country if sample_`S', local(L)
    local C : word count `L'
    display as text "`S' raw complete-case observations: `N'"
    display as text "`S' countries: `C'"
}

egen tag_country = tag(country_id)

bys country_id: egen T_f7 = total(sample_f7)
display as text "Countries with at least $JIE_MINOBS observations in Figure 7 system:"
levelsof country if tag_country & T_f7 >= $JIE_MINOBS, local(included_f7)
local nincl_f7 : word count `included_f7'
display as text "Figure 7 included countries: `nincl_f7'"

display as text "Countries excluded by the $JIE_MINOBS-observation rule in Figure 7 system:"
levelsof country if tag_country & T_f7 < $JIE_MINOBS, local(excluded_f7)
local nexcl_f7 : word count `excluded_f7'
display as text "Figure 7 excluded countries: `nexcl_f7'"

bys country_id: egen T_f9 = total(sample_f9)
display as text "Countries with at least $JIE_MINOBS observations in Figure 9 system:"
levelsof country if tag_country & T_f9 >= $JIE_MINOBS, local(included_f9)
local nincl_f9 : word count `included_f9'
display as text "Figure 9 included countries: `nincl_f9'"

display as text "Countries excluded by the $JIE_MINOBS-observation rule in Figure 9 system:"
levelsof country if tag_country & T_f9 < $JIE_MINOBS, local(excluded_f9)
local nexcl_f9 : word count `excluded_f9'
display as text "Figure 9 excluded countries: `nexcl_f9'"

drop tag_country T_f7 T_f9

log close _audit
