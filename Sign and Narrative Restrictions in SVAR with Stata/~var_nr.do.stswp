*VAR_NR: Stata module to estimate set identified SVARS

*https://econpapers.repec.org/software/bocbocode/s458992.htm

/*
Abigail Kuchek (abigail.kuchek@dal.frb.org), 
Jonah Danziger (jonah.danziger@dal.frb.org) 
and Christoffer Koch (International Monetary Fund)
*/

/*
Abstract: The toolbox var_nr allows for the estimation of set
 identified SVARS in Stata using sign and narrative restrictions. 
 The suite is able to produce impulse responses functions, 
 forecast error variance decompositions, and historical 
 decompositions. These postestimation commands can also be used 
 in conjunction with standard point identified SVARs with short- 
 or long-run restrictions.
*/

// Install the package

ssc install var_nr

// Clear the console and the data

cls
clear
graph drop _all // + Drop the previous PNG graph

// Change the folder for the current directory

cd "C:\Users\jamel\Dropbox\stata\var_nr"

// Open a log to produce a PDF file at the end

capture log close                               
log using var_nr.log, replace

// Open the help file of the package

help var_nr

/*
Keep in mind that
ident specifies the method for identifying the VAR. 
This option will accept one of three strings: 
"oir", "bq", or "sr". "oir" specifies zero short-run restrictions; 
"bq" specifies zero long-run restrictions; 
and "sr" specifies [narrative] sign restrictions.
*/


**# /* Long-run Zero Restrictions */

clear *
use data_longrun
tsset date

// estimate var
var GDPGrowth Unemployment, lags(1/4)
var_nr bq, var("VAR") opt("opts")
var_nr_options_display , optname("opts") all

// Change options

var_nr_options , optname("opts") savefmt("png") pctg(68)
var_nr_options_display , optname("opts") all

mata
// only plot GDP growth
opts.shck_plt = "GDPGrowth"

// compute IRF, bands, plot
IRF = irf_funct(VAR,opts)
IRFB = irf_bands_funct(VAR,opts)
irf_plot(IRF,IRFB,VAR,opts)

// compute FEVD, bands, plot
FEVD = fevd_funct(VAR,opts)
FEVDB = fevd_bands_funct(VAR,opts)
fevd_plot(FEVD,FEVDB,VAR,opts)

// compute HD, plot
HD = hd_funct(VAR,opts)
hd_plot(HD,VAR,opts)
end

**# /* Narrative Sign Restrictions */

/*
Keep in mind that Code for this function is adapted 
from Ambrogio Cesa-Bianchi's VAR Toolbox.  
Code follows Kilian and Lutkepohl's notation in Structural 
Vector Autoregressive Analysis (2016). Also for IRF, HD and 
FEDV.
*/

clear *
use data_narrsignrestrict
tsset date

// estimate var
var lninflat lnunempl lnfedfunds, lags(1/2) exog(trend)
var_nr sr, varname("v") opt("opts") lintrend(trend)
var_nr_options_display , optname("opts") all

// narrative restriction: positive Oct 79 (q4 '79)
loc Volcker_disinfl_pf = yq(1979,4)

mata
ns = nr_create(v)
nr_set(yq(1979,4),yq(1979,4),"+","Monetary Policy Shock","",ns)

// load matrices into associative array to prep for calculations
s = shock_create(v)
shock_name(("Supply Shock","Demand Shock","Monetary Policy Shock"),s)

shock_set(1,1,"-","Supply Shock","lninflat",s)
shock_set(1,1,"-","Supply Shock","lnunempl",s)
shock_set(1,1,"-","Supply Shock","lnfedfunds",s)

shock_set(1,1,"+","Demand Shock","lninflat",s)
shock_set(1,1,"-","Demand Shock","lnunempl",s)
shock_set(1,1,"+","Demand Shock","lnfedfunds",s)

shock_set(1,1,"-","Monetary Policy Shock","lninflat",s)
shock_set(1,1,"+","Monetary Policy Shock","lnunempl",s)
shock_set(1,1,"+","Monetary Policy Shock","lnfedfunds",s)

// set options
opts = opt_set()
opts.ndraws = 1000
opts.updt = "yes"
opts.updt_frqcy = 1000

opts.save_fmt="png"
opts.pctg=68
opt_display(opts)

// run narrative sign restrictions routine
stata("set seed 123456")
SR = narr_sign_restrict(v,s,opts,ns)

// IRF, FEVD, HD calculations
IRF_set = sr_analysis_funct("irf",SR,opts)
FEVD_set = sr_analysis_funct("fevd",SR,opts)
HD_set = sr_analysis_funct("hd",SR,opts)

// plot and save
irf_plot(asarray(IRF_set,"median"),asarray(IRF_set,"bands"),v,opts)
fevd_plot(asarray(FEVD_set,"median"),asarray(FEVD_set,"bands"),v,opts)
hd_plot(asarray(HD_set,"median"),v,opts)
end

**# /* Short-run Zero Restrictions */

clear *
use data_shortrun
tsset date

// estimate var
var Inflat Unempl FedFunds, lags(1/2) exog(trend trendsq)
var_nr oir, varname("VAR") optname("A") lintr(trend) quadtr(trendsq)
var_nr_options_display , optname("A") all

mata
// only plot Inflation
A.shck_plt = "Inflat"
A.save_fmt="png"
A.pctg=68
opt_display(A)

// IRF
IRF = irf_funct(VAR,A)
IRFB = irf_bands_funct(VAR,A)

// FEVD
FEVD = fevd_funct(VAR,A)
FEVDB = fevd_bands_funct(VAR,A)

// HD
HD = hd_funct(VAR,A)

// plot all of the above
irf_plot(IRF,IRFB,VAR,A)
fevd_plot(FEVD,FEVDB,VAR,A)
hd_plot(HD,VAR,A)
end

log close _all