version 18.0

do "code/00_config.do"

log using "$JIE_LOG/00_run_all_requested_figures.log", replace text

display as text "Preparing annual panel..."
do "$JIE_CODE/01_prepare_annual_panel.do"

display as text "Loading Mata backend..."
do "$JIE_LIB/jie_bvar_mata.do"

display as text "Running sample audit..."
do "$JIE_CODE/02_sample_audit.do"

display as text "Building Figure 3..."
do "$JIE_CODE/20_figure3_panel_bvar.do"

display as text "Building Figure 4..."
do "$JIE_CODE/21_figure4_acts_threats.do"

display as text "Building Figure 5..."
do "$JIE_CODE/22_figure5_global_country.do"

display as text "Building Figure 6..."
do "$JIE_CODE/23_figure6_narrative.do"

display as text "Building Figure 7..."
do "$JIE_CODE/24_figure7_units_estimators.do"

display as text "Building Figure 9..."
do "$JIE_CODE/25_figure9_spillovers.do"

display as result "Done. See:"
display as result "  $JIE_DER"
display as result "  $JIE_FIG"
display as result "  $JIE_LOG"

log close
