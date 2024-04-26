****************************************************************
/*
https://www.piie.com/blogs/realtime-economics/2024/
 united-states-wants-work-friendly-and-minded-countries
 -so-who-are

https://www.nato.int/cps/en/natohq/
 topics_52044.htm?selectedLocale=en
*/

use Hendrix_FriendlyLikeMinded.dta, clear

label variable idealpointdistance                            ///
 "UNGA ideal point, mean absolute distance to the US, 2020–22"
 
label variable polyarchy_absdistance                         ///
 "Polarchy score mean absolute distance to the US, 2020–22"

*NATO countries
// Loop to select countries
gen nato = 0

foreach v in TUR CZE SWE SVN SVK GBR ROU PRT POL NLD         ///
 NOR MNE MKD NLD MNE LUX LTU LVA ITA ISL HUN GRC DEU         ///
 FRA FIN EST DNK HRV CAN BGR BEL {
  replace nato = 1 if iso3c == "`v'"  	
}

 
*Reproduce Figure 1*
label define natolab 0 "Non-NATO" 1 "NATO"
label values nato natolab

kountry iso3c, from(iso3c) to(iso2c)
rename _ISO2C_ iso2c
 
twoway (                                                     ///
  scatter polyarchy_absdistance idealpointdistance,          ///
  mlabel(iso2c) colorvar(nato) colordiscrete legend(off)     ///
  zlabel(, valuelabel) coloruseplegend                       ///
  ytitle("") xtitle("")                                      ///
  title("Mean absolute distance with the US")                ///
  name(piie, replace)                                        ///
  text(.7 .5 "{bf:Polyarchy score}", size(small))            ///
  text(.1 4.5 "{bf:UNGA ideal point}", size(small))          ///
  colorlist(blue*0.4%80 red*0.5%80)                          ///
  xline(2.5) yline(.4)                                       ///
  )

*Generate Factor Variable*
factor polyarchy_absdistance idealpointdistance
predict f_friendlylikeminded

sort f_friendlylikeminded

graph export piie.png, width(4000) as(png)                   ///
 name("piie") replace

****************************************************************