# unmarked-paper

Analysis code for Kellner KF, et al. "The unmarked R package: Twelve years of advances in occurrence and abundance modeling in ecology".

This analysis is fully reproducible using the following steps.

1. Install the `renv` package, e.g. with `install.packages('renv')`.
2. Run `renv::restore()` in this directory. This downloads and locally installs the exact versions of the R packages specified in the `renv.lock` file (it should not affect your existing R package library).
3. Compile the Rmarkdown document by running `rmarkdown::render("unmarked_Paper_Analysis.Rmd")`. As part of this process, output will be tested to make sure it matches expected results.

This will yield two files: an HTML file with the analysis results, and a TIFF image (Figure 4 in the paper).

Alternatively you can build the Docker image by running `make docker` in this directory at the command line, assuming you have the appropriate software installed.
In this case, after the Docker image is built the two resulting output files will be copied into a new `docker-output` directory.

# DATA LIABILITY DISCLAIMER AND TERMS

Although the bird survey data contained in `acfl_roanoke_river.csv` have undergone substantial review prior to posting, errors or inaccuracies may still exist in the data.  Thus, this data should be regarded as provisional since subsequent reviews may result in significant revisions to the data. 

These data have been processed successfully on computer systems within the Division of Strategic Habitat Conservation (DSHC), U.S. Fish & Wildlife Service (USFWS), however no warranty expressed or implied is made regarding the accuracy or utility of the data on any other system or for general or scientific purposes, nor shall the act of distribution constitute any such warranty. This disclaimer applies both to individual use of the data and aggregate use of the data. It is strongly recommended that these data are directly acquired from a USFWS, DSHC source, and not indirectly through other sources which may have changed the data in some way. The USFWS shall not be held liable for improper or incorrect use of the data described and/or contained herein.