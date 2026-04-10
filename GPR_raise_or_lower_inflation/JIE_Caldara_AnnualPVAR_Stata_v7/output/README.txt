This folder is populated when you run code/00_run_all_requested_figures.do in Stata.


Version v5 notes
- Figure scripts now export both .dta and .csv IRF datasets in output/derivatives/.
- Confidence bands are drawn with darker opacity for easier visual inspection.
- Legends now explicitly label median lines and 90% bands.
- For Figures 7 and 9, the shaded band is the inverse-variance weighted (IVW) 90% posterior band, matching the intended design.


V6 update:
- Figures 7 and 9 now draw explicit q05 and q95 boundary lines around the IVW band.
- This makes narrow confidence bands visually detectable even when the shaded area collapses onto the median line.

V7 update: Figures 3-6 now include explicit q05 and q95 boundary lines in addition to shaded 90% bands.
