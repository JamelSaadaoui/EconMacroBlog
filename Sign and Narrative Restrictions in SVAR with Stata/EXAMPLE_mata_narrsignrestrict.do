/* Narrative Sign Restrictions */

clear *
use data_narrsignrestrict
tsset date

// estimate var
v lninflat lnunempl lnfedfunds, lags(1/2) exog(trend)
v_nr sr, vname("v") opt("opts") lintrend(trend)

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