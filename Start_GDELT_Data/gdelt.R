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

library(ggplot2)
theme_set(
  theme_classic() +
    theme(legend.position = "top")
)

ex1 <- GetGDELTStability(location="FR",
                         var_to_get="instability",
                         time_resolution="15min",
                         smoothing=1,
                         num_days=180)

ex2 <- GetGDELTStability(location="IS",
                         var_to_get="instability",
                         time_resolution="day",
                         smoothing=1,
                         num_days=180)

ggplot(data=ex1, aes(x = Datetime, y = instability))+
  geom_line()

ggplot(data=ex2, aes(x = Date, y = instability))+
  geom_line()

###############################################################################
