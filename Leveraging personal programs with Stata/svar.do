capture program drop svarjamel

cd "C:\Users\jamel\Downloads\"
do "svarjamel.ado"

use database_pri_gpr.dta, clear

global X lrpo lpro ldem lpri

svarjamel

