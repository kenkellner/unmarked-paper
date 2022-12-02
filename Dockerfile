# Start with R version 4.2.2
FROM rocker/r-ver:4.2.2

# Install some linux libraries that R packages need
RUN apt-get update && apt-get install -y \
  pandoc \
  libcurl4-openssl-dev \
  libfontconfig1-dev \
  libssl-dev \
  cmake \
  libxml2-dev \
  libxt6

# Set renv version 0.15.5
ENV RENV_VERSION 0.15.5

# Install renv
RUN Rscript -e "install.packages('http://cran.r-project.org/src/contrib/Archive/renv/renv_${RENV_VERSION}.tar.gz', repos=NULL, type='source')"

# Create a working directory
WORKDIR /unmarked-paper

# Install all R packages specified in renv.lock
COPY renv.lock renv.lock
RUN Rscript -e 'renv::restore()'

# Copy necessary files
COPY unmarked_Paper_Analysis.Rmd unmarked_Paper_Analysis.Rmd
COPY acfl_roanoke_river.csv acfl_roanoke_river.csv

# Run analysis
RUN Rscript -e "rmarkdown::render('unmarked_Paper_Analysis.Rmd')"

# Copy other files
COPY README.md README.md

# Default to bash terminal when running docker image
CMD ["bash"]
