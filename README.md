# Intensity_measurement

The files necessary for intensity measurements: (found on the share under "intensity_scripts")

1. Use "plot_profile" in Fiji to get the values for peaks and with a certain cell type as identifier
2. Use "csvmutation.R" in R to creat two types of csv:
	a) the overview where the name and cell type are stored
	b) the individual, changed csvs where the cell type is removed, the columns are labelled X and Y, and the X values are changed to the 128nm intervals
3. Use peakdetect_RI.py (which calls peakdetect_bergmann.py) to subtract background based on the second peak, fit a Gaussian and output:
	a) a plot.png where the fit and FMHW are added. Use this to manually/visually control the data
	b) a csv "data_output.csv" with the names and area stored
4. Use area_processing.R to merge the overview with data output into a single csv and save this. Now it contains Names, Values and CellType.
5. Use plot_intensities.R to plot the measured and processed intensities.
  This is to be improved. Currently it works with two types (G1 and Anaphase) from the same strain. But mixing several strains, each with 2-3 phases, has to be workable. This requires a consistent naming scheme for the microscopy images that has yet to be decided.
