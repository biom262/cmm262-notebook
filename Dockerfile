FROM ucsdets/datahub-base-notebook:2023.1-stable

USER root

ARG modulename

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
    manpages=5.05-1 \
    man-db=2.9.1-1 \
    manpages-posix=2013a-2 \
    tree=1.8.0-1 \
    && rm -rf /var/lib/apt/lists/*

RUN conda config --set channel_priority strict && \
    mamba install -y -n base -c conda-forge --override-channels bash_kernel nb_conda_kernels

COPY ${modulename}.yml /tmp
RUN mamba env create --file /tmp/${modulename}.yml && \
    mamba clean -afy

RUN yes | unminimize || echo "done"

USER $NB_USER