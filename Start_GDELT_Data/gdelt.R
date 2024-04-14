###############################################################################

install.packages("GDELTtools")

library(GDELTtools)


data <- GetGDELT(start_date="2016-09-16", end_date="2016-09-16",
                 row_filter=Actor1Code=="USA" & Actor2Code=="CHN",
                 contains("date"), starts_with("actor"))

data1 <- GetGDELT(start_date="2016-09-16", end_date="2016-09-16",
                 row_filter=Actor1Code=="USA" & Actor2Code=="CHN")

library(xlsx)
write.xlsx(data, "C:/Users/jamel/Dropbox/PC/Downloads/data.xlsx")
write.xlsx(data1, "C:/Users/jamel/Dropbox/PC/Downloads/data1.xlsx")

###############################################################################


