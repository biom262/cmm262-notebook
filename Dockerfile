# -----------------
# Build1 Container
# Stats env
# -----------------

FROM ucsdets/datahub-base-notebook:2023.1-stable as build1
#USER root

RUN conda config --set channel_priority strict && \
mamba install -y -n base -c conda-forge --override-channels bash_kernel nb_conda_kernels conda-lock 

COPY /env/stats.yml /tmp/stats.yml
RUN conda-lock lock --platform linux-64 --file /tmp/stats.yml --kind lock --lockfile /tmp/stats-conda-lock.yml
RUN conda-lock install --mamba --copy --prefix /opt/stats /tmp/stats-conda-lock.yml
#RUN conda-lock install -n stats /tmp/stats-conda-lock.yml 
#&& mamba clean -afy && \

#UNCOMMENT THIS AFTER to attempt multipe 
# RUN conda-lock install \
#     --mamba \
#     --copy \ 
#     --prefix /opt/env \
#     /tmp/stats.conda-lock.yml && \
#     mamba clean -afy

# -----------------
# Build2 Container
# Chip-seq env
# -----------------

# FROM ucsdets/datahub-base-notebook:2023.1-stable as build2
# COPY chipseq.yml /tmp/chipseq.yml
# RUN conda-lock lock --platform linux-64 --file /tmp/chipseq.yml --kind lock --lockfile /tmp/chipseq-conda-lock.yml
# RUN conda-lock install -n chipseq /tmp/chipseq-conda-lock.yml && mamba clean -afy




# COPY /original-env/gwas.yml /tmp/gwas.yml
# COPY /original-env/imgproc.yml /tmp/imgproc.yml
# COPY programming-R.yml /tmp/programming-R.yml
# COPY rna-seq.yml /tmp/rna-seq.yml
# COPY spatial-tx.yml /tmp/spatial-tx.yml


#&& \
# conda-lock lock --platform linux-64 --file /tmp/gwas.yml --kind lock --lockfile /tmp/gwas-conda-lock.yml && \
# conda-lock lock --platform linux-64 --file /tmp/imgproc.yml --kind lock --lockfile /tmp/imgproc-conda-lock.yml && \
# conda-lock lock --platform linux-64 --file /tmp/programming-R.yml --kind lock --lockfile /tmp/programming-R-conda-lock.yml && \
# conda-lock lock --platform linux-64 --file /tmp/rna-seq.yml --kind lock --lockfile /tmp/rna-seq-conda-lock.yml && \
# conda-lock lock --platform linux-64 --file /tmp/spatial-tx.yml --kind lock --lockfile /tmp/spatial-tx-conda-lock.yml && \
# conda-lock lock --platform linux-64 --file /tmp/chipseq.yml --kind lock --lockfile /tmp/chipseq-conda-lock.yml


# RUN conda-lock install -n gwas /tmp/gwas-conda-lock.yml && mamba clean -afy
# RUN conda-lock install -n imgproc /tmp/imgproc-conda-lock.yml && mamba clean -afy
# RUN conda-lock install -n programming-R /tmp/programming-R-conda-lock.yml && mamba clean -afy
# RUN conda-lock install -n rna-seq /tmp/rna-seq-conda-lock.yml && mamba clean -afy
# RUN conda-lock install -n spatialtx /tmp/spatial-tx-conda-lock.yml && mamba clean -afy
# RUN conda-lock install -n chipseq /tmp/chipseq-conda-lock.yml && mamba clean -afy


# -----------------
# Primary container
# -----------------

FROM ucsdets/datahub-base-notebook:2023.1-stable as final
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
    manpages=5.05-1 \
    man-db=2.9.1-1 \
    manpages-posix=2013a-2 \
    tree=1.8.0-1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build1 /opt/stats /opt/conda/envs/stats
#ENV PATH="/opt/conda/envs/bin:${PATH}"

# COPY scrna-seq.yaml /tmp
# RUN mamba env create --file /tmp/scrna-seq.yaml && \
#     mamba clean -afy
# COPY variant_calling.yml /tmp
# RUN mamba env create --file /tmp/variant_calling.yml && \
#     mamba clean -afy

RUN yes | unminimize || echo "done"

USER $NB_USER
