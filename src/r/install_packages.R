# Install the R packages used by titanic_model.R
# rocker/r-ver:4.4.1 installs from a dated CRAN snapshot, so the package versions are fixed
install.packages("dplyr")

# install.packages() only warns on failure, so stop the Docker build if dplyr is missing
stopifnot(requireNamespace("dplyr", quietly = TRUE))
