***************************************************
*  Exports data to Matlab
***********************

// Load the main dataset
use CICP_JIE.dta, clear

// Define all variables to be exported to Matlab
// Includes original variables, decomposed components (sgprco_c, sgprco_w), 
// narrative shock indicators, and control variables
global keepvars "sgprco gprh lngdp_detrend milit_exp_share inflation_sig impexp_gdp_ratio_detrend lt_rate st_rate debttogdp gmoney_sig std_shortages_c shortagesc_share gtogdp gprco sgpaco sgptco gdp ggdp sgprco_c sgprco_w gpr_narrative gpr_narrative_dummy gpr_narrative_ai gpr_narrative_top3 gmd_strate_win gmd_ltrate_win gmd_dusdfx_win gprco_others inflation_trim gmoney_trim"

// Reload dataset (redundant but kept for safety)
use CICP_JIE.dta, clear
codebook countrycode
tab countrycode


// Define sample period boundaries
global first_year = 1900 //Start year of sample
global last_year = 2023  //End year of sample




//--------------------------------------------------
// DECOMPOSE SGPRCO INTO WITHIN AND BETWEEN COMPONENTS
//--------------------------------------------------

// Regress sgprco on country fixed effects and country-specific GPR_H trends
// This removes country-specific variation
reg sgprco i.country i.country#c.L(0).gprh

// Extract within-country component (residuals after removing country FE)
predict sgprco_c, res

// Calculate between-country component (original minus within)
gen sgprco_w = sgprco - sgprco_c

// Format variables for display
format sgprco %5.2f
format inflation_sig %5.2f











//--------------------------------------------------
// CREATE NARRATIVE SHOCK INDICATORS
//--------------------------------------------------

// Regress sgprco on country FE, lagged sgprco, and country-specific GPR_H
// This controls for persistence and common factors
reg sgprco i.country  i.country#c.L(1).sgprco i.country#c.L(0).gprh

// Get residuals - these represent "unexpected" shocks
predict sgprco_res, res

// Display observations with large positive shocks (>3 standard deviations)
list country year if sgprco_res>3 & sgprco_res~=.

// Create continuous narrative shock variable (zero for normal periods)
gen gpr_narrative = 0
replace gpr_narrative = sgprco_res if sgprco_res>3 & sgprco_res~=.

// Create binary narrative shock indicator
gen gpr_narrative_dummy = 0
replace gpr_narrative_dummy = 1 if sgprco_res>3 & sgprco_res~=.






//--------------------------------------------------
// IDENTIFY TOP 3 SHOCKS PER COUNTRY
//--------------------------------------------------

// Rank shocks within each country (1 = largest shock)
bysort country: egen desired_rank=rank(-sgprco_res), track

// Keep only top 3 shocks per country
gen gpr_narrative_top3 = 0
replace gpr_narrative_top3 = sgprco_res if desired_rank <= 3 & desired_rank~=.

// Display the top 3 shocks for each country
list country year if gpr_narrative_top3>0








//--------------------------------------------------
// CREATE AI-VALIDATED NARRATIVE SHOCKS
//--------------------------------------------------

// Start with top 3 shocks
gen gpr_narrative_ai = gpr_narrative_top3

// Flag for shocks to be excluded (non-genuine shocks identified through historical analysis)
gen gpr_narrative_exclude = 0

// Exclude specific country-year observations that represent 
// non-genuine shocks (e.g., data issues, anticipated events, etc.)

* Argentina
replace gpr_narrative_exclude = 1 if countrylong=="Argentina" & year==1962

* Brazil
replace gpr_narrative_exclude = 1 if countrylong=="Brazil" & year==1962

* Chile
replace gpr_narrative_exclude = 1 if countrylong=="Chile" & year==1973

* Colombia
replace gpr_narrative_exclude = 1 if countrylong=="Colombia" & year==1901
replace gpr_narrative_exclude = 1 if countrylong=="Colombia" & year==1948

* Indonesia
replace gpr_narrative_exclude = 1 if countrylong=="Indonesia" & year==1958

* Malaysia
replace gpr_narrative_exclude = 1 if countrylong=="Malaysia" & year==2014

* Peru
replace gpr_narrative_exclude = 1 if countrylong=="Peru" & year==2022
replace gpr_narrative_exclude = 1 if countrylong=="Peru" & year==2023

* South Africa
replace gpr_narrative_exclude = 1 if countrylong=="South Africa" & year==1985

* Thailand
replace gpr_narrative_exclude = 1 if countrylong=="Thailand" & year==1972

* Venezuela
replace gpr_narrative_exclude = 1 if countrylong=="Venezuela" & year==2019

// Set excluded shocks to zero in AI-validated series
replace gpr_narrative_ai = 0 if gpr_narrative_exclude==1









//--------------------------------------------------
// SUMMARY STATISTICS
//--------------------------------------------------

// Display summary of top 3 and AI-validated shocks
summarize gpr_narrative_top3 if gpr_narrative_top3>0
summarize gpr_narrative_ai if gpr_narrative_ai>0

// Count AI-validated shocks by country
bysort country: egen count_gpr_narrative_ai_country = total(gpr_narrative_ai > 0 & !missing(gpr_narrative_ai))
tabulate country count_gpr_narrative_ai_country if count_gpr_narrative_ai_country > 0

// Count AI-validated shocks by year
bysort year: egen count_gpr_narrative_ai_year = total(gpr_narrative_ai > 0 & !missing(gpr_narrative_ai))

// Count non-AI-validated shocks (excluded shocks) by year
bysort year: egen count_gpr_nonnarrative_ai_year = total(gpr_narrative_top3 > 0 & !missing(gpr_narrative_top3) & gpr_narrative_ai==0)

// Display years with AI-validated shocks
tabulate year count_gpr_narrative_ai_year if count_gpr_narrative_ai_year > 0

// Sort and list all top 3 shocks with their AI validation status
sort country year
list country year gpr_narrative_ai gpr_narrative_top3 if gpr_narrative_top3>0





//--------------------------------------------------
// CREATE AVERAGE GPR FOR ALL OTHER COUNTRIES
//--------------------------------------------------

// For each country-year, calculate the average GPR of all other countries
// This creates a measure of global GPR excluding own-country effects

// Calculate total GPR across all countries by year
bysort year: egen year_total_gprco = sum(gprco)

// Count number of countries with data in each year
bysort year: egen year_total_countries = count(gprco)

// Calculate average GPR of other countries
// Formula: (total GPR - own GPR) / (number of countries - 1)
gen gprco_others = (year_total_gprco - gprco) / (year_total_countries - 1)

// Add variable label
label variable gprco_others "Average gprco of all other countries in same year"

// Clean up temporary variables
drop year_total_gprco year_total_countries












//--------------------------------------------------
// PREPARE DATA FOR EXPORT TO MATLAB
//--------------------------------------------------

// Sort data and create time index within each country
sort country year
bysort country : gen timevar = _n

//--------------------------------------------------
// EXPORT COUNTRY NAMES
//--------------------------------------------------

// Get list of all countries
levelsof countrylong
local cnames = r(levels)

// Open text file to write country names
file open cc using "pvar\countrynames.txt", text write replace

// Define the last country (for comma formatting)
local last_country "Vietnam"

// Write country names separated by commas
foreach ctry of local cnames {
	if "`ctry'" == "`last_country'"  {
		file write cc "`ctry'"  // No comma after last country
	} 
	else {
		file write cc "`ctry'" "," 
	}
}

// Close the country names file
file close cc

//--------------------------------------------------
// CREATE EXPORT VARIABLES WITH x_ PREFIX
//--------------------------------------------------

// Create copies of all variables with x_ prefix for export
foreach var of varlist $keepvars {
    gen x_`var' = `var'
}

// Keep only export variables and identifiers
keep x_* countrycode timevar

// Store list of all x_ variables (excluding identifiers)
quietly ds countrycode timevar, not
global finalvars `r(varlist)'

//--------------------------------------------------
// RESHAPE DATA FROM LONG TO WIDE FORMAT
//--------------------------------------------------

// Reshape: Each variable becomes T×N matrix (years × countries)
// After reshape: x_sgprco1, x_sgprco2, ..., x_sgprco44
//                x_gdp1, x_gdp2, ..., x_gdp44, etc.
quietly reshape wide x_*, i(timevar) j(countrycode)

//--------------------------------------------------
// PREPARE FOR MATLAB EXPORT
//--------------------------------------------------

// Replace missing values with 9999 (Matlab convention)
quietly recode x_* (.=9999)

// Order variables sequentially
order *, seq

//--------------------------------------------------
// EXPORT EACH VARIABLE AS SEPARATE TXT FILE
// Commented out below since variables are already in the replication folder
//--------------------------------------------------

/*

// Loop through each variable and export as T×N matrix
foreach x of global finalvars {
	// Extract variable name without x_ prefix for filename
	local varname = subinstr("`x'", "x_", "", 1)
	di "Exporting: `varname'"
	
	// Expand to get all country columns for this variable (1-44)
	// This ensures we only export columns for this specific variable
	// (e.g., x_sgprco1-44, not x_sgprco_c1-44 or x_sgprco_w1-44)
	unab vars : `x'1-`x'44
	
	// Export as CSV file: rows = years (124), columns = countries (44)
	export delimited `vars' using "pvar\data_`varname'.txt", replace novarnames delim(,)
}