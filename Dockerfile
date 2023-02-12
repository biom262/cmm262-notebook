FROM ucsdets/datahub-base-notebook:2023.1-stable

USER root

RUN sed -i 's:^path-exclude=/usr/share/man:#path-exclude=/usr/share/man:' \
        /etc/dpkg/dpkg.cfg.d/excludes

# install linux packages
RUN apt-get update && \
    apt-get install tk-dev \
                    tcl-dev \
                    cmake \
                    wget \
                    default-jdk \
                    libbz2-dev \
                    apt-utils \
                    gdebi-core \
                    dpkg-sig \
                    man \
                    man-db \
                    manpages-posix \
                    tree \
                    -y

# RUN conda config --set channel_priority strict && \
RUN mamba install -y -n base -c conda-forge --override-channels bash_kernel nb_conda_kernels

# create scanpy_2021 conda environment with required python packages
COPY scanpy_2021.yaml /tmp
RUN mamba env create --file /tmp/scanpy_2021.yaml && \
    mamba clean -afy

COPY variant_calling.yml /tmp
RUN mamba env create --file /tmp/variant_calling.yml && \
    mamba clean -afy

COPY programming-R.yaml /tmp
RUN mamba env create --file /tmp/programming-R.yaml && \
    mamba clean -afy

COPY chipseq.yml /tmp
RUN mamba env create --file /tmp/chipseq.yml && \
    mamba clean -afy

COPY gwas.yml /tmp
RUN mamba env create --file /tmp/gwas.yml && \
    mamba clean -afy

COPY stats.yml /tmp
RUN mamba env create --file /tmp/stats.yml && \
    mamba clean -afy

COPY spatial-tx.yml /tmp
RUN mamba env create --file /tmp/spatial-tx.yml && \
    mamba clean -afy

RUN yes | unminimize || echo "done"

USER $NB_USER
