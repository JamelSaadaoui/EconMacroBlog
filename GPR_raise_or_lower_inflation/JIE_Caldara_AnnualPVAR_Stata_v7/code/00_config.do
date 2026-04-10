version 18.0

capture log close _all
clear all
set more off
set linesize 255
set scheme s2color

* ----------------------------------------------------------------------
* Project paths
* Run Stata from the unzipped project folder.
* ----------------------------------------------------------------------
global JIE_ROOT "`c(pwd)'"
global JIE_CODE "$JIE_ROOT/code"
global JIE_LIB  "$JIE_CODE/lib"
global JIE_OUT  "$JIE_ROOT/output"
global JIE_DER  "$JIE_OUT/derived"
global JIE_FIG  "$JIE_OUT/figures"
global JIE_LOG  "$JIE_OUT/logs"

* Preferred location of the uploaded annual file
global JIE_RAW  "$JIE_ROOT"

cap mkdir "$JIE_OUT"
cap mkdir "$JIE_DER"
cap mkdir "$JIE_FIG"
cap mkdir "$JIE_LOG"

* ----------------------------------------------------------------------
* Estimation controls
* ----------------------------------------------------------------------
global JIE_P       1
global JIE_H       10
global JIE_NDRAWS  5000
global JIE_MINOBS  60
global JIE_SEED    20260407

set seed $JIE_SEED
