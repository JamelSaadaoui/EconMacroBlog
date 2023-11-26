**#** Data frequency transformation **

*https://www.jamelsaadaoui.com/dentons-method-with-stata/

cls // clear the console
clear // clear the data
 
global folder = "C:\Users\jamel\Documents\GitHub\EconMacroBlog\"
// We store strings in a shorter name
display "$folder" // We check the global variable

global code "Dentons_method_with_Stata\"
// We store strings in a shorter name
display "$code" // We check the global variable

webuse usmacro, clear
tsset

global frequency_transform = "frequency_transform\"
display "$frequency_transform"

cd ${folder}
cd ${code}
cd ${frequency_transform}

drop if date<tq(1956q1)
tsset, quarterly

save usmacro, replace

twoway (line fedfunds date) (line ogap date) ///
 (line inflation date), name(G2, replace)

global frequency_transform_figures = ///
 "frequency_transform_figures\"
display "$frequency_transform_figures"

*cd ${frequency_transform_figures} 
 
// Export figures to the desired folder

graph export ${frequency_transform_figures}G2.pdf, ///
 as(pdf) replace
graph export "${frequency_transform_figures}G2.png", ///
 as(png) replace

describe
summarize

*help collapse

*help yofd()
*help dofq()

gen year=yofd(dofq(date))

collapse (mean) fedfunds inflation ogap, by(year)

list

twoway (line fedfunds year) (line ogap year) ///
 (line inflation year), name(G3, replace)

graph export ${frequency_transform_figures}G3.pdf, ///
 as(pdf) replace
graph export "${frequency_transform_figures}G3.png", ///
 as(png) replace

describe
summarize

format %ty year

tsset year, yearly

save usmacro_ann.dta, replace

use usmacro_ann.dta, clear
assert _N == 55

cap /// 
denton inflation using usmacro_denton.dta, ///
 interp(inflation) from(usmacro.dta) generate(rate) stock 
 
use usmacro_denton.dta, clear

twoway (line rate date) ///
 , name(G4, replace)

graph export ${frequency_transform_figures}G4.pdf, ///
 as(pdf) replace
graph export "${frequency_transform_figures}G4.png", ///
 as(png) replace
 
drop inflation
 
merge 1:1 date using usmacro.dta 
drop _merge

twoway (line inflation rate date) ///
 , name(G5, replace)
 
graph export ${frequency_transform_figures}G5.pdf, ///
 as(pdf) replace
graph export "${frequency_transform_figures}G5.png", ///
 as(png) replace