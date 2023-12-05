FROM ucsdets/datahub-base-notebook:2023.1-stable

USER root

RUN sed -i 's:^path-exclude=/usr/share/man:#path-exclude=/usr/share/man:' \
    /etc/dpkg/dpkg.cfg.d/excludes

# install linux packages
RUN apt-get update && apt-get install -y \
    tk-dev=8.6.9+1 \
    tcl-dev=8.6.9+1 \
    cmake=3.16.3-1ubuntu1.20.04.1 \
    wget=1.20.3-1ubuntu2 \
    default-jdk=2:1.11-72 \
    libbz2-dev=1.0.8-2 \
    apt-utils=2.0.9 \
    gdebi-core=0.9.5.7+nmu3 \
    dpkg-sig=0.13.1+nmu4 \
    && rm -rf /var/lib/apt/lists/*

USER $NB_USER
