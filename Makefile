
#
# Variables
#

# RStudio
RSTUDIO_VERSION=rstudio-server-2024.04.2-764-amd64

# Ubuntu version
UBUNTU_CODENAME := $(shell lsb_release -cs)

#
# Targets
#
.PHONY = install install-base install-r install-sits install-rstudio install-cuda

#
# Base
#
install-base:  ## Install base dependencies
	apt-get update -y \
    && apt-get install -y --no-install-recommends \
    gdal-bin git \
    htop \
    lbzip2 \
    libfftw3-dev \
    libcairo2-dev \
    libgdal-dev libgeos-dev libgit2-dev libgsl0-dev \
    libgl1-mesa-dev  libglu1-mesa-dev \
    libhdf4-alt-dev libhdf5-dev \
    libjq-dev \
    libnetcdf-dev \
    libpq-dev libproj-dev libprotobuf-dev \
    libsqlite3-dev libssl-dev \
    libudunits2-dev libunwind-dev \
    netcdf-bin \
    postgis protobuf-compiler \
    rsync \
    sqlite3 \
    texlive-latex-base tk-dev \
    unixodbc-dev \
    vim \
    wget \
    qpdf \
    texlive-fonts-extra \
    texlive-latex-extra \
    texlive-latex-recommended \
    texlive-fonts-recommended \
    ghostscript \
    libharfbuzz-dev \
	libfribidi-dev \
	gdebi-core \
	libclang-dev

#
# R language
#
install-r:  ## Install R language
	apt update -y \
    && apt install -y \
        gnupg2 \
        software-properties-common \
	    gpg \
        gpg-agent \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(UBUNTU_CODENAME)-cran40/" \
    && apt update -y \
    && apt-get install -y --no-install-recommends \
        r-base \
        r-base-dev \
        r-recommended \
        littler 

	# Configure litter
	ln -s /usr/share/doc/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/share/doc/littler/examples/install2.r /usr/local/bin/install2.r \
    && install.r docopt

	# Install R dependencies
	install2.r --error \
    classInt \
    deldir \
    geosphere gstat \
    hdf5r \
    mapdata \
    ncdf4 \
    proj4 \
    RColorBrewer RNetCDF \
    raster \
	rlas \
    sf \
	sp \
	spacetime \
	spatstat \
	spdep \
    rmarkdown \
    Rcpp \
    knitr \
    testthat \
    remotes \
    qpdf \
    shiny \
    pacman \
    covr \
    withr \
    devtools \
    renv \
	torch \
	torchopt \
	luz \
	tmap

#
# SITS R Package
#
install-sits:  ## Install SITS R Package
	# Install sits
	git clone --branch dev https://github.com/e-sensing/sits \
	&& cd sits \
	&& echo "remotes::install_deps(dependencies = TRUE)" | R --no-save \
	&& echo "devtools::install('.')" | R --no-save

	# Install sitsdata
	git clone https://github.com/e-sensing/sitsdata \
	&& cd sitsdata \
	&& echo "devtools::install('.')" | R --no-save

	rm -rf sits sitsdata

#
# RStudio
#
install-rstudio:  ## Install RStudio
	wget https://download2.rstudio.org/server/focal/amd64/$(RSTUDIO_VERSION).deb --no-check-certificate \
    && gdebi $(RSTUDIO_VERSION).deb -n \
    && rm $(RSTUDIO_VERSION).deb \
    && mkdir -p /var/lib/rstudio-server/monitor/log/ \
    && chown rstudio-server:rstudio-server /var/lib/rstudio-server/monitor/log/

#
# CUDA for R
#
install-cuda:  ## Install CUDA (11.8)
	wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin \
	&& mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
	&& apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub \
	&& add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" \
	&& apt install cuda-11-8 cuda-toolkit-11-8 -y \
	&& echo "install.packages('torch')" | R --no-save \
	&& echo 'torch::install_torch(type = "11.8")' | R --no-save

#
# General installation target
#
install: install-base install-r install-sits install-rstudio install-cuda
	echo "all dependencies installed!"

#
# Documentation function (thanks for https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)
#
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
