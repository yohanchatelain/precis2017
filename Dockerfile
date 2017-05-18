FROM frolvlad/alpine-glibc

MAINTAINER Loic Gouarin "loic.gouarin@gmail.com"

# Configure environment
ENV CONDA_DIR=/opt/conda CONDA_VER=4.3.11
ENV PATH=$CONDA_DIR/bin:$PATH SHELL=/bin/bash LANG=C.UTF-8

# Install useful packages 
RUN apk --update add \
    bash \
    curl \
    git \
    ca-certificates \
    tini \
    libice \
    libsm \
    libstdc++ &&\
    rm -rf /var/cache/apk/*

# get and install miniconda
RUN curl https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh  -o mconda.sh && \
    /bin/bash mconda.sh -f -b -p $CONDA_DIR && \
    rm mconda.sh && \
    rm -rf $CONDA_DIR/pkgs/*

COPY environment.yml environment.yml
RUN conda env create -f environment.yml &&\
    rm -rf $CONDA_DIR/pkgs

ENV PATH=$CONDA_DIR/envs/precis/bin:$PATH
ENV CONDA_ENV_PATH=$CONDA_DIR/envs/precis
ENV CONDA_DEFAULT_ENV=precis

RUN adduser -s /bin/bash -D precis

EXPOSE 1234
# Configure container startup
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "lab", "--ip=*", "--port=1234" ,"--no-browser"]

USER precis

# Clone the shifman files into the docker container
RUN git clone https://github.com/ReScience-Archives/Shifman-2017.git shifman

RUN mkdir -p /home/precis/.config/matplotlib &&\
    echo "backend      : Agg" >> /home/precis/.config/matplotlib/matplotlibrc    