FROM rocker/r-ver:3.6.0

RUN apt-get update && apt-get -y install --no-install-recommends \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY docker/bin /usr/local/bin/
RUN sed  -i'' '/mran.microsoft.com/d' /usr/local/lib/R/etc/Rprofile.site

RUN install_packages --repo=https://mrc-ide.github.io/drat \
    getPass \
    glue \
    httr \
    jsonlite \
    mockery \
    testthat \
    tibble \
    withr \
    xml2

COPY . /src
