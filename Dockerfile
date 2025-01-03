#modified from https://github.com/avanetten/simrdwn/blob/master/docker/Dockerfile
#https://github.com/joe-siyuan-qiao/DetectoRS/blob/master/docker/Dockerfile

ARG PYTORCH="1.3"
ARG CUDA="10.1"
ARG CUDNN="7"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

MAINTAINER ShengChu

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0+PTX"
ENV TORCH_NVCC_FLAGS="-Xfatbin -compress-all"
ENV CMAKE_PREFIX_PATH="$(dirname $(which conda))/../"
ENV DEBIAN_FRONTEND=noninteractive

# install requirements
RUN apt-get update && apt-get install -y --no-install-recommends \
            libglib2.0-0 \
            libsm6 \
            libxrender-dev \
            libxext6 \
            apt-utils \
	    bc \
	    bzip2 \
	    ca-certificates \
	    curl \
	    git \
	    libgdal-dev \
	    libssl-dev \
	    libffi-dev \
	    libncurses-dev \
	    libgl1 \
	    jq \
	    nfs-common \
	    parallel \
	    python3-dev \
	    python3-pip \
	    python3-wheel \
	    python3-setuptools \
	    unzip \
	    vim \
	    tmux \
	    sudo \
	    cmake \
	    ninja-build \
	    wget \
	    build-essential \
        libopencv-dev \
        protobuf-compiler \
        libprotobuf-dev \
        python-opencv \
	  && apt-get clean \
	  && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]
ENV PATH /opt/conda/bin:$PATH

# prepend pytorch and conda-forge before default channel
RUN conda update conda && \
    conda config --prepend channels conda-forge

RUN conda install -y gdal=2.4.2 \				 
	          geopandas=0.6.3 \
	          fiona \
		  rasterio \
	     	  awscli \
	          affine \
	          pyproj \
	          pyhamcrest \
	          cython \
	          fiona \
	          h5py \
	          ncurses \
	          jupyter \
	          jupyterlab \
	          ipykernel \
	          libgdal \
	          matplotlib \
		  ncurses \
	          numpy==1.16.4 \
	          statsmodels \
	          pandas \
	          pillow \
	          pip \
	          scipy \
	          scikit-image \
	          scikit-learn \
	          shapely \
	          rtree \
	          testpath \
	          tqdm \
		  opencv \
	          statsmodels \
		  testpath \
		  rtree \
                  matplotlib \
                  pycocotools \
                  pyyaml \
                  packaging \
                  tensorboardX \
                  tensorboard \
                  tensorflow-gpu=1.13.1 \
               
	&& conda clean -p \
	&& conda clean -t \
	&& conda clean --yes --all 



#install DetectoRS
RUN conda clean --all
RUN apt-get install -y --no-install-recommends

#install cocoapi
RUN pip install "git+https://github.com/open-mmlab/cocoapi.git#subdirectory=pycocotools"

# set FORCE_CUDA because during `docker build` cuda is not accessible
ENV FORCE_CUDA="1"

# because inside `docker build`, there is no way to tell which architecture will be used.
ARG TORCH_CUDA_ARCH_LIST="Kepler;Kepler+Tesla;Maxwell;Maxwell+Tegra;Pascal;Volta;Turing"
ENV TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST}"

ENV FVCORE_CACHE="/tmp"

#RUN pip install "git+https://github.com/Sheng1994/DetectoRS-master-UNOSAT.git"

RUN git clone -b detectors https://github.com/Sheng1994/UNOSAT-Building-Footprint.git /DetectoRS && cd /DetectoRS && pip install --no-cache-dir -e .
RUN export DetectoRS=$PWD
RUN export PYTHONPATH=$DetectoRS:$PYTHONPATH


RUN pip install mmcv

RUN export PYTHONIOENCODING='utf_8'
RUN export LANG=C.UTF-8

WORKDIR /workspace/Buildingfootprint

RUN ["/bin/bash"]
