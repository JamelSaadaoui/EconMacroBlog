version 18.0

capture log close _prep
log using "$JIE_LOG/01_prepare_annual_panel.log", replace text name(_prep)

local src1 "$JIE_RAW/datapanelGPR_long.xlsx"
local src2 "$JIE_ROOT/raw/datapanelGPR_long.xlsx"

capture confirm file "`src1'"
if _rc {
    capture confirm file "`src2'"
    if _rc {
        display as error "Could not find datapanelGPR_long.xlsx in:"
        display as error "  `src1'"
        display as error "  `src2'"
        exit 601
    }
    local src "`src2'"
}
else {
    local src "`src1'"
}

display as text "Importing `src'"

import excel using "`src'", firstrow clear

compress
order country_id country year
sort country_id year

capture isid country_id year
if _rc {
    display as error "country_id year is not unique."
    exit 459
}

xtset country_id year

label var country_id "Country numeric identifier"
label var country    "Country name"
label var year       "Calendar year"

save "$JIE_DER/annual_panel.dta", replace

display as result "Saved: $JIE_DER/annual_panel.dta"

log close _prep
