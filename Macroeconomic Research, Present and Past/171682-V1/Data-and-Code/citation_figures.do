
**set drive root

clear all
set graphics off

**Note: this file makes use of user written command grc1leg
**uncomment the line below to install it
*net install grc1leg,from( http://www.stata.com/users/vwiggins/)


****************************************
**Figure 5: Aggregate Citation Patterns
****************************************
use "citation_panel_data.dta", clear
set scheme s1color

//CREATE KEY VARIABLES
bys id (year): gen  cumcites = sum(cites)
bys id (year): gen  cumarticles = sum(articles)
bys id (year): gen  cumarticlesJEL = sum(JEL_articles)
gen GE=1 if journal=="AER"|journal=="Econometrica"|journal=="JPE"|journal=="QJE"|journal=="RES"
replace GE=0 if GE!=1
gen citesratio=cumcites/cumarticles if GE==0
replace citesratio=cumcites/cumarticlesJEL if GE==1

//DROPS THE TWO NEWEST PAPERS IN SAMPLE
drop if paper_id==9|paper_id==10

//COLLAPSE DATA TO AGGREGATED JOURNAL LEVEL
tempfile main
save `main'
collapse (sum) AGGcumcites=cumcites (sum) AGGcumarticles=cumarticles if GE==0 & journal!="RED" & journal!="AEJ", by(journal years_since GE)
tempfile agg
save `agg'
use `main'
append using `agg'
save `main', replace

collapse (sum) AGGcumcites=cumcites (sum) AGGcumarticlesJEL=cumarticlesJEL if GE==1, by(years_since GE)
tempfile GEagg
save `GEagg'
use `main'
append using `GEagg'
save `main', replace


sort paper_id year
gen AGGcitesratio=AGGcumcites/AGGcumarticles if GE==0
replace AGGcitesratio=AGGcumcites/AGGcumarticlesJEL if GE==1

replace journal = "G.I." if journal==""
drop if paper_id==1|paper_id==2|paper_id==3|paper_id==4|paper_id==5|paper_id==6|paper_id==7|paper_id==8|paper_id==9|paper_id==10
replace id=1 if journal=="JME"
replace id=2 if journal=="JMCB" 
replace id=3 if journal=="JEDC" 
replace id=4 if journal=="G.I."

//COLLAPSE TO CREATE LINE REPRESENTING THE AVERAGE ACROSS ALL JOURNALS
save `main', replace
collapse (sum) TOTcumcites=AGGcumcites (sum) TOTcumarticles=AGGcumarticles (sum) TOTcumarticlesJEL=AGGcumarticlesJEL, by(years_since)
tempfile TOT 
save `TOT'
use `main'
append using `TOT'

sort id  years_since
gen TOTcitesratio=TOTcumcites/(TOTcumarticles+TOTcumarticlesJEL)

replace journal="Aggregrate" if journal==""
replace id=5 if journal=="Aggregrate"

	
//CREATE GRAPHS
drop if years_since > 30

xtline AGGcitesratio, overlay t(years_since) i(id) plot1(lc(navy)) plot2(lc(navy*0.60)) plot3(lc(navy*0.30)) plot4(lc(gs12)) xlabel(0(5)36) ylabel(,angle(0)) ytitle("") xtitle("Years Since Publication") ylabel( 0 (0.01) 0.05) ///
addplot((line TOTcitesratio years_since if inlist(id, 5), ms(none) lc(black) lwidth(thick)) (scatter AGGcitesratio years_since if years_since==30, ms(none) mla(journal) mlabsize(medium) mlabc(black)) (scatter TOTcitesratio years_since if years_since==30 & inlist(id, 5), ms(none) mla(journal) mlabsize(medium) mlabc(black) mlabposition(1))) ///
legend(off)

graph export Fig5_CitationsAgg.pdf, replace


*****************************************************
**Figure 6: Citation Patterns for Individual Articles
*****************************************************

use "citation_panel_data.dta", clear
set scheme s1color

//CREATE KEY VARIABLES
drop if journal=="RED" | journal=="AEJ" | year<1990
bys id (year): gen  cumcites = sum(cites)
bys id (year): gen  cumarticles = sum(articles)
bys id (year): gen  cumarticlesJEL = sum(JEL_articles)
gen GE=1 if journal=="AER"|journal=="Econometrica"|journal=="JPE"|journal=="QJE"|journal=="RES"
replace GE=0 if GE!=1
gen citesratio=cumcites/cumarticles if GE==0
replace citesratio=cumcites/cumarticlesJEL if GE==1

//COLLAPSE ALL GENERAL INTEREST CITATIONS INTO ONE LINE
tempfile panel

save `panel'

collapse(sum) GEcumcites=cumcites (sum) GEcumarticles=cumarticlesJEL if GE==1, by(paper_id year)
tempfile GE	
save `GE'

use `panel'
append using `GE'
drop if GE==1
sort paper_id year
gen GEcitesratio=GEcumcites/GEcumarticles
replace journal = "G.I." if journal==""

replace cumcites=GEcumcites if journal=="G.I."
replace cumarticles=GEcumarticles if journal=="G.I."


//COLLAPSE DATA TO AGGREGATED JOURNAL LEVEL
save `panel', replace
collapse (sum) AGGcumcites=cumcites (sum) AGGcumarticles=cumarticles, by(paper_id year)
tempfile agglines
save `agglines', replace
use `panel'
append using `agglines'

sort paper_id year
gen AGGcitesratio=AGGcumcites/AGGcumarticles

replace journal = "Aggregate" if journal==""

replace paper = "KPR 1988" if paper_id==1 & paper==""
replace paper = "Taylor 1993" if paper_id==2 & paper=="" 
replace paper = "Calvo 1983" if paper_id==3 & paper=="" 
replace paper = "Rotemburg & Woodford 1997" if paper_id==4 & paper==""
replace paper = "Kiyotaki & Moore 1997" if paper_id==5 & paper==""
replace paper = "Romer & Romer 1989" if paper_id==6 & paper=="" 
replace paper = "Blanchard & Quah 1988" if paper_id==7 & paper==""
replace paper = "Bernanke & Gertler 1989" if paper_id==8 & paper==""
replace paper = "CCE 2005" if paper_id==9 & paper==""
replace paper = "Smets & Wouters 2007" if paper_id==10 & paper==""

//GENERATE NEW IDS SO YOU CAN PLOT THE AGREGATE PAPER DATA WITH THE JOURNAL SPECIFIC DATA
egen new_id=group(paper journal)
sort new_id

// FIELD + GI GRAPHS FOR ALL 10 PAPERS
xtline citesratio if inlist(new_id, 3,4,5), overlay plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(bg1989) title(Bernanke & Gertler (1989)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 2), ylabel(,angle(0)) ms(none) lc(gs12) sort) (line AGGcitesratio year if inlist(new_id, 1), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1)  sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 8,9,10), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(bq1988) title(Blanchard & Quah (1988)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 7), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 6), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 13,14,15), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(cce2005) title(CEE (2005)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 12), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 11), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 18,19,20), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(calvo1983) title(Calvo (1983)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 17), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 16), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 23,24,25), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(kpr1988) title(KPR (1988)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 22), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 21), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 28,29,30), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(km1997) title(Kiyotaki & Moore (1997)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 27), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 26), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 33,34,35), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(rr1989) title(Romer & Romer (1989)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 32), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 31), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 38,39,40), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(rw1997) title(Rotemberg & Woodford (1997)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 37), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 36), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 43,44,45), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(sw2007) title(Smets & Wouters (2007)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 42), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 41), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

xtline citesratio if inlist(new_id, 48,49,50), overlay  plot1(lc(maroon*0.4)) plot2(lc(maroon*0.7)) plot3(lc(maroon)) name(taylor1993) title(Taylor (1993)) nodraw ///
addplot((line GEcitesratio year if inlist(new_id, 47), ylabel(,angle(0)) ms(none) lc(gs12)  sort) (line AGGcitesratio year if inlist(new_id, 46), ylabel(,angle(0)) ytitle("") xtitle("") ms(none) lwidth(thick) lc(black) ylabel( 0 (0.02) 0.1) sort)) ///
legend(order(1 "JEDC" 2 "JMCB" 3 "JME" 4 "G.I. Journals" 5 "Aggregate") size(small) bmargin(0 13 5 0) col(1))

//10 GRAPHS IN 1 PLOT
grc1leg  calvo1983 bq1988 kpr1988 rr1989 bg1989 taylor1993 km1997 rw1997 cce2005 sw2007, col(4) ring(0) position(5) name(paper_panel, replace)
graph display paper_panel, xsize(9) ysize(7.5) scale(.85)
graph export Fig6_CitationsPapers.pdf, replace

