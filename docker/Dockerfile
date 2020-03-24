FROM rocker/r-ver:3.6.0

RUN apt-get update

COPY docker/bin /usr/local/bin/
RUN sed  -i'' '/mran.microsoft.com/d' /usr/local/lib/R/etc/Rprofile.site

RUN install_packages --repo=https://mrc-ide.github.io/drat \
    getPass \
    glue \
    httr \
    xml2 \
    mockery \
    testthat \
    withr

COPY . /src
