**# First tests of the Global Macroeconomic Database by
*Müller, Xu, Lehbib, and Chen (2025)

**# Start of Program

cd C:\Users\jamel\Dropbox\stata\gmd

capture log close _all                                
log using GDM_Jan25.log, name(GDM_Jan25) text replace

clear

net install GMD, from(http://www.globalmacrodata.com/package)

global CS1 "nGDP rGDP rGDP_pc inv inv_GDP finv finv_GDP rcons cons cons_GDP imports imports_GDP exports CA CA_GDP pop govexp govexp_GDP govrev govrev_GDP govtax govtax_GDP govdef govdef_GDP govdebt govdebt_GDP CPI HPI deflator infl unemp USDfx REER strate ltrate cbrate M0 M1 M2 M3 M4 BankingCrisis CurrencyCrisis SovDebtCrisis"

GMD $CS1, country() version(2025_01)

des

encode ISO3, generate(cn)

xtset cn year

tsfill, full

order cn, first

decode cn, generate(iso3c)

order cn iso3c, first

kountry iso3c, from(iso3c)

rename NAMES_STD country 

order cn iso3c country, first

drop countryname ISO3

xtdescribe

summ $CS1

tabstat $CS1, stat(count)

tabstat $CS1, stat(count) by(cn) save
return list

putexcel set "tabstat", replace sheet(Stats)

putexcel set "tabstat", modify sheet(Stats)
forvalues v=1(1)243 {
          putexcel (A`v') = (r(name`v'))
		  putexcel (B`v') = matrix(r(Stat`v'))
		}

*https://www.statalist.org/forums/forum/general-stata-discussion/general/1473382-exporting-variable-label-with-putexcel
		
putexcel set filename, replace
local row = 1
foreach x of varlist $CS1 {
describe `x'
local varlabel : var label `x'
putexcel A`row' = ("`varlabel'")
local row = `row'+1
}

gen LREER=log(REER)
gen LrGDP_pc=log(rGDP_pc)

areg CA_GDP L5.LREER L5.LrGDP_pc, absorb(cn year) rob

kountry iso3c, from(iso3c) to(imfn)

rename _IMFN_ imfcode
rename cn cn_
rename imfcode cn

group_dummy

areg CA_GDP L10.LREER L10.LrGDP_pc if ssa==1, ///
 absorb(cn year) rob

tabstat $CS1 if ssa==1, stat(count) by(cn_) save
 
save GDM_Jan25.dta, replace

putexcel set "tabstat_ssa", modify sheet(Stats)
forvalues v=1(1)243 {
          putexcel (A`v') = (r(name`v'))
		  putexcel (B`v') = matrix(r(Stat`v'))
		}

log close _all
exit

**# End of Program for the Local Projections