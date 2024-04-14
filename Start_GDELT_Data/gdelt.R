###############################################################################

install.packages("GDELTtools")

library(GDELTtools)


data <- GetGDELT(start_date="2016-09-26", end_date="2016-09-26",
                 row_filter=Actor1Code=="USA" & Actor2Code=="CHN",
                 contains("date"), starts_with("actor"))

data1 <- GetGDELT(start_date="2016-09-26", end_date="2016-09-26",
                 row_filter=Actor1Code=="USA" & Actor2Code=="CHN")

library(xlsx)
write.xlsx(data, "C:/Users/jamel/Documents/GitHub/EconMacroBlog/Start_GDELT_Data")
write.xlsx(data1, "C:/Users/jamel/Documents/GitHub/EconMacroBlog/Start_GDELT_Data")

###############################################################################


