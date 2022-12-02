# unmarked-paper

Analysis code for Kellner KF, et al. "The unmarked R package: Twelve years of advances in occurrence and abundance modeling in ecology".

This analysis is fully reproducible using the following steps.

1. Copy the data file `acfl_roanoke_river.csv` into this directory.
2. Install the `renv` package, e.g. with `install.packages('renv')`.
3. Run `renv::restore()` in this directory. This downloads and locally installs the exact versions of the R packages specified in the `renv.lock` file (it should not affect your existing R package library).
4. Compile the Rmarkdown document by running `rmarkdown::render("unmarked_Paper_Analysis.Rmd")`. As part of this process, output will be tested to make sure it matches expected results.

This will yield two files: an HTML file with the analysis results, and a TIFF image (Figure 4 in the paper).

Alternatively you can build the Docker image by running `make docker` in this directory at the command line, assuming you have the appropriate software installed.
In this case, after the Docker image is built the two resulting output files will be copied into a new `docker-output` directory.
