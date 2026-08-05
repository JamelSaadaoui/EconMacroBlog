version 16.0
cls
clear all
set more off

*-------------------------------------------------------------------------------
* Portable project paths
* The do-file may be launched from the root, code, data, or results directory
*-------------------------------------------------------------------------------

local here "`c(pwd)'"
local here : subinstr local here "\" "/", all

local last_folder = lower(substr( ///
    "`here'", ///
    strrpos("`here'", "/") + 1, ///
    . ///
))

if inlist("`last_folder'", "code", "data", "results") {
    quietly cd ..
}

global main_path "`c(pwd)'"
global code      "${main_path}/code"
global data      "${main_path}/data"
global results   "${main_path}/results"

cd "`c(pwd)'"

/*
Execution dependencies

- Run Part 0 first to install the packages and define the globals.
- Parts 2 and 3 require the component CSV files created in Part 1.
- Part 4 requires the merged file produced in Part 3.
- Part 7 requires the annual CSV files and rename map created in
  Parts 5 and 6.
- Part 8 requires the component CSV files created in Part 1.
- Part 9 requires the frames created in Part 8.
- Part 10 requires the linked frames produced in Parts 8 and 9.
*/

// =============================================================================
// PART 0 — INSTALL THE PACKAGES AND DEFINE THE PROJECT PATHS
// =============================================================================

// Install or update the packages
ssc install combineall, replace
ssc install editanything, replace

which combineall
which editanything

// Main project directories and files
global CA_ROOT        "C:/Users/jamel/Dropbox/stata/combineall"
global CA_INPUTS      "$CA_ROOT/grunfeld_merge_inputs"
global CA_MERGED      "$CA_ROOT/grunfeld_merged_raw.dta"
global CA_FINAL       "$CA_ROOT/grunfeld_panel_final.dta"

// Files used for the harmonization example
global CA_ANNUAL      "$CA_ROOT/grunfeld_annual_inputs"
global CA_MAP         "$CA_ROOT/grunfeld_rename_map.csv"
global CA_HARMONIZED  "$CA_ROOT/grunfeld_harmonized_1935_1937.dta"

// Files produced by the frames example
global CA_FRAME_FINAL "$CA_ROOT/grunfeld_panel_from_frames.dta"
global CA_FRAMESET    "$CA_ROOT/grunfeld_workflow"

// Create the required directories
capture mkdir "$CA_ROOT"
capture mkdir "$CA_INPUTS"
capture mkdir "$CA_ANNUAL"

// Display the project paths
display "$CA_ROOT"
display "$CA_INPUTS"


// =============================================================================
// PART 1 — CREATE THREE COMPONENT FILES FROM THE GRUNFELD PANEL
// =============================================================================

webuse grunfeld, clear

describe
isid company year

assert _N == 200

/*
combineall currently requires string identifiers for merge and joinby.

The F and Y prefixes ensure that import delimited retains the identifiers
as strings rather than interpreting them as numeric variables.
*/

gen str3 firm_id = "F" + strtrim(strofreal(company))
gen str5 year_id = "Y" + strtrim(strofreal(year))

order company year firm_id year_id invest mvalue kstock

isid firm_id year_id

// -----------------------------------------------------------------------------
// Investment file
// -----------------------------------------------------------------------------

preserve

    keep firm_id year_id invest

    export delimited using ///
        "$CA_INPUTS/investment.csv", replace

restore

// -----------------------------------------------------------------------------
// Market-value file
// -----------------------------------------------------------------------------

preserve

    keep firm_id year_id mvalue

    export delimited using ///
        "$CA_INPUTS/market_value.csv", replace

restore

// -----------------------------------------------------------------------------
// Capital-stock file
// -----------------------------------------------------------------------------

preserve

    keep firm_id year_id kstock

    export delimited using ///
        "$CA_INPUTS/capital_stock.csv", replace

restore

// Verify the files
dir "$CA_INPUTS/*.csv"


// =============================================================================
// PART 2 — INSPECT THE FILES WITH EDITANYTHING
// =============================================================================

// Find the installed combineall ado-file without opening it
editanything combineall, showpath

return list

display "`r(file)'"
display "`r(basename)'"
display "`r(extension)'"
display r(size)

// Render the combineall help file in the editor
editanything combineall.sthlp, editor

// Display the raw CSV file without importing it
editanything "$CA_INPUTS/investment.csv", editor
// Display the raw CSV file without importing it
editanything "$CA_INPUTS/capital_stock.csv", editor
// Display the raw CSV file without importing it
editanything "$CA_INPUTS/market_value.csv", editor

/*
Optional: create a new Markdown project note.

Run this command only once. The new option correctly returns an error if
the file already exists.
*/

// editanything "$CA_ROOT/workflow_notes", new extension(md)


// =============================================================================
// PART 3 — MERGE ALL THREE CSV FILES WITH COMBINEALL
// =============================================================================

combineall using "$CA_MERGED",             ///
    cmethod(merge)                         ///
    directory("$CA_INPUTS")                ///
    filetype(csv)                          ///
    mtype(1:1)                             ///
    mvars(firm_id year_id)                 ///
    replace

// Display the stored results
return list

assert r(n_files) == 3


// =============================================================================
// PART 4 — LOAD AND VALIDATE THE MERGED PANEL
// =============================================================================

use "$CA_MERGED", clear

// Verify that the final merge produced complete matches
assert _merge == 3
drop _merge

// Recover conventional numeric panel identifiers
gen byte company = real(subinstr(firm_id, "F", "", 1))
gen int  year    = real(subinstr(year_id, "Y", "", 1))

order company year firm_id year_id invest mvalue kstock
sort company year

// Validate the merge
isid company year

assert _N == 200
assert !missing(invest, mvalue, kstock)

// Declare the panel
xtset company year

xtdescribe

summarize invest mvalue kstock

list company year invest mvalue kstock in 1/12, ///
    sepby(company)

// Save the validated panel
compress

save "$CA_FINAL", replace


// =============================================================================
// PART 5 — ADVANCED HARMONIZATION EXAMPLE
// =============================================================================

/*
This example creates three annual files.

The variable is called invest_old in 1935 and 1936, but invest in 1937.
combineall will use a map file to harmonize the variable name before
appending the three releases.
*/

webuse grunfeld, clear

keep if inrange(year, 1935, 1937)

// -----------------------------------------------------------------------------
// Annual file for 1935
// -----------------------------------------------------------------------------

preserve

    keep if year == 1935

    rename invest invest_old

    drop year

    export delimited using ///
        "$CA_ANNUAL/grunfeld_1935.csv", replace

restore

// -----------------------------------------------------------------------------
// Annual file for 1936
// -----------------------------------------------------------------------------

preserve

    keep if year == 1936

    rename invest invest_old

    drop year

    export delimited using ///
        "$CA_ANNUAL/grunfeld_1936.csv", replace

restore

// -----------------------------------------------------------------------------
// Annual file for 1937
// -----------------------------------------------------------------------------

preserve

    keep if year == 1937

    drop year

    export delimited using ///
        "$CA_ANNUAL/grunfeld_1937.csv", replace

restore

// Verify the annual files
dir "$CA_ANNUAL/*.csv"


// =============================================================================
// PART 6 — CREATE THE VINTAGE-AWARE RENAME MAP
// =============================================================================

clear

input str20 oldname str20 newname firstyear lastyear
"invest_old" "invest" 1935 1936
end

list, noobs

export delimited using "$CA_MAP", replace


// =============================================================================
// PART 7 — APPEND AND HARMONIZE THE ANNUAL RELEASES
// =============================================================================

combineall using "$CA_HARMONIZED",         ///
    cmethod(append)                        ///
    directory("$CA_ANNUAL")                ///
    filetype(csv)                          ///
    map("$CA_MAP")                         ///
    strict                                 ///
    replace

return list

assert r(n_files) == 3
assert r(n_missing) == 0

// Load and validate the harmonized panel
use "$CA_HARMONIZED", clear

sort company year

isid company year

assert _N == 30
assert inrange(year, 1935, 1937)
assert !missing(invest)

tabulate year

summarize invest mvalue kstock

// Display the provenance information
char list invest[source]


// =============================================================================
// PART 8 — LOAD THE COMPONENT FILES INTO SEPARATE FRAMES
// =============================================================================

/*
Warning: frames reset removes every dataset currently held in memory.
All important results have already been saved above.
*/

frames reset

// Reestablish the globals if this part is run in a new Stata session
global CA_ROOT        "C:/Users/jamel/Dropbox/stata/combineall"
global CA_INPUTS      "$CA_ROOT/grunfeld_merge_inputs"
global CA_FRAME_FINAL "$CA_ROOT/grunfeld_panel_from_frames.dta"
global CA_FRAMESET    "$CA_ROOT/grunfeld_workflow"

// -----------------------------------------------------------------------------
// Investment frame
// -----------------------------------------------------------------------------

frame rename default investment

frame investment: import delimited using ///
    "$CA_INPUTS/investment.csv", clear

// -----------------------------------------------------------------------------
// Market-value frame
// -----------------------------------------------------------------------------

frame create market

frame market: import delimited using ///
    "$CA_INPUTS/market_value.csv", clear

// -----------------------------------------------------------------------------
// Capital-stock frame
// -----------------------------------------------------------------------------

frame create capital

frame capital: import delimited using ///
    "$CA_INPUTS/capital_stock.csv", clear

// Display all datasets currently in memory
frames dir


// =============================================================================
// PART 9 — LINK THE THREE FRAMES
// =============================================================================

// Verify the identifiers within each frame
frame investment: isid firm_id year_id
frame market:     isid firm_id year_id
frame capital:    isid firm_id year_id

// Make investment the current frame
frame change investment

// Link the investment and market-value frames
frlink 1:1 firm_id year_id, frame(market)

frget mvalue, from(market)

// Link the investment and capital-stock frames
frlink 1:1 firm_id year_id, frame(capital)

frget kstock, from(capital)

// Validate the retrieved variables
assert !missing(invest, mvalue, kstock)

// Recover numeric panel identifiers
gen byte company = real(subinstr(firm_id, "F", "", 1))
gen int  year    = real(subinstr(year_id, "Y", "", 1))

order company year firm_id year_id invest mvalue kstock
sort company year

isid company year

assert _N == 200

xtset company year

xtdescribe

summarize invest mvalue kstock

list company year invest mvalue kstock in 1/12, ///
    sepby(company)

// Save a clean standalone panel while preserving the live frame links
capture frame drop panel_clean

frame put company year firm_id year_id ///
    invest mvalue kstock, into(panel_clean)

frame panel_clean: compress
frame panel_clean: save "$CA_FRAME_FINAL", replace

frame drop panel_clean

// Keep the three datasets available for inspection
frames dir

// Uncomment to open the final frame in the Data Editor
// browse company year invest mvalue kstock


// =============================================================================
// PART 10 — SAVE THE COLLECTION OF FRAMES
// =============================================================================

/*
frames save and the .dtas frameset format require Stata 18 or later.
*/

if c(stata_version) >= 18 {

    frames save "$CA_FRAMESET",             ///
        frames(investment market capital)   ///
        replace
}


// =============================================================================
// END OF THE EXAMPLE
// =============================================================================

display as result ///
    "Complete example finished successfully."

display as text ///
    "Merged panel: $CA_FINAL"

display as text ///
    "Harmonized panel: $CA_HARMONIZED"

display as text ///
    "Frame-based panel: $CA_FRAME_FINAL"

frames dir