**#  Analysing US-CHN tensions on oil price
*---------------------------------------------------------------

version 18.0
set more off
cd "C:\Users\jamel\Dropbox\stata\lpirf"
capture log close                               
log using blog-lpirf.smcl, replace

import excel .\data_svar.xlsx,/*
*/ sheet("data") firstrow clear

generate mth = tm(1960m1) + _n-1
format %tm mth

label variable pri "Political Relationship Index"
label variable pri_s "PRI Standardized"
label variable gop "Global Oil Production"
label variable rspri "Real Spot Price"
label variable wip "World Industrial Production"
label variable dinv "Variation of Inventories"
label variable gprcn ///
	  "Percent of Articles on China in the Bil. GPR"

rename gop pro
rename wip dem
rename rspri rpo

capture generate lpro = log(pro)
la var lpro "Natural log of PRO"
capture generate lrpo = log(rpo)
la var lpro "Natural log of RPO"
capture generate ldem = log(dem)
la var ldem "Natural log of DEM"

drop t
order mth, first

/* Another transformation for the PRI index */
gen lpri = sign(pri) * log(1 + abs(pri))

/*

In the "Short-run SVAR models" section of the "[TS] var intro" manual 
(PDF documentation) you can see that 

     A*epsilon_t = B*e_t
     
Where e_t is the matrix of structural shocks and epsilon_t is the matrix of
the residuals for the reduced form VAR model. Therefore,

     e_t = inv(B)*A*epsilon_t 
     
Below is an example that computes the structural shocks (e_t).

*/

**#  Declare time series

tsset mth, monthly

matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matlist A

matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
matlist B

svar lpri lpro ldem lrpo if mth>tm(2000m1), aeq(A) beq(B) ///
lags(1/24) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var lpri lpro ldem lrpo if mth>tm(2000m1)
capture drop epsilon*
predict double epsilon1 if mth>tm(2000m1),residual eq(#1)
predict double epsilon2 if mth>tm(2000m1),residual eq(#2)
predict double epsilon3 if mth>tm(2000m1),residual eq(#3)
predict double epsilon4 if mth>tm(2000m1),residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat epsilon*, matrix(epsilon) 
/* compute e_t matrix of structural shocks */
matrix e = (BA*epsilon')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double e

twoway (tsline e1 if mth>tm(2000m1)) (tsline epsilon1 ///
if mth>tm(2000m1), yaxis(1)), ///
 name(G1, replace)
 
graph export "G1.svg", as(svg) replace

irf set comparemodels.irf, replace
quietly lpirf lpro ldem lrpo, step(48) lags(1/24) ///
  exog(L(0/24).e1)
irf create lpmodel 

quietly var lpro ldem lrpo, lags(1/24)            ///
  exog(L(0/24).e1)
irf create varmodel, step(48)

irf graph dm, impulse(e1) response(lrpo)   ///
  irf(lpmodel varmodel) level(95) name(G2, replace) ///
    xline(0 10 20 30 40 50, lcolor(blue)) ///
	  yline(-.05 0 .05 .1, lcolor(blue))

graph export "G2.svg", replace

/* GPR */

svar gprcn lpro ldem lrpo if mth>tm(2000m1), aeq(A) beq(B) ///
lags(1/24) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var gprcn lpro ldem lrpo if mth>tm(2000m1)
capture drop epsilon*
predict double epsilon1 if mth>tm(2000m1),residual eq(#1)
predict double epsilon2 if mth>tm(2000m1),residual eq(#2)
predict double epsilon3 if mth>tm(2000m1),residual eq(#3)
predict double epsilon4 if mth>tm(2000m1),residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat epsilon*, matrix(epsilon) 
/* compute e_t matrix of structural shocks */
matrix e_ = (BA*epsilon')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double e_

twoway (tsline e_1 if mth>tm(2000m1)) (tsline epsilon1 ///
if mth>tm(2000m1), yaxis(1)), ///
 name(G3, replace)
 
graph export "G3.svg", as(svg) replace

irf set comparemodels1.irf, replace
quietly lpirf lpro ldem lrpo, step(48) lags(1/24) ///
  exog(L(0/24).e_1)
irf create lpmodel1

quietly var lpro ldem lrpo, lags(1/24)            ///
  exog(L(0/24).e_1)
irf create varmodel1, step(48)

irf graph dm, impulse(e_1) response(lrpo)   ///
  irf(lpmodel1 varmodel1) level(95) name(G4, replace) ///
    xline(0 10 20 30 40 50, lcolor(blue)) ///
	 yline(-.05 0 .05 .1, lcolor(blue))

graph export "G4.svg", replace

twoway (tsline e_1 if mth>tm(2000m1)) (tsline e1 ///
if mth>tm(2000m1), yaxis(1)), ///
 name(G5, replace)
 
graph export "G5.svg", replace

save lpirf_EEter, replace