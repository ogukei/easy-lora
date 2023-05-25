
FROM continuumio/miniconda3:latest AS compile-image

ENV PYTHON_VERSION=3.10
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y curl git wget software-properties-common
RUN apt install -y libsndfile1-dev

# conda
RUN conda create --name conda python=${PYTHON_VERSION} pip
RUN python3 -m pip install --no-cache-dir --upgrade pip

RUN chsh -s /bin/bash
SHELL ["/bin/bash", "-c"]

# step 2
FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

RUN apt-get update && \
    apt-get install -y curl git wget

# user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID
# create user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
# set user
USER $USERNAME

COPY --from=compile-image --chown=$USERNAME /opt/conda /opt/conda
ENV PATH /opt/conda/bin:$PATH

# env
ENV HF_HOME=/home/user/.cache/huggingface

# shell
SHELL ["/bin/bash", "-c"]

# app
WORKDIR /app/
RUN git clone https://github.com/kohya-ss/sd-scripts.git
WORKDIR /app/sd-scripts
RUN git reset --hard 16e5981d3153ba02c34445089b998c5002a60abc

# config
COPY --chown=$USERNAME default_config.yaml $HF_HOME/accelerate/default_config.yaml

# install
WORKDIR /app/sd-scripts

RUN source activate conda && \
  pip install torch==1.12.1+cu116 torchvision==0.13.1+cu116 \
    --extra-index-url https://download.pytorch.org/whl/cu116 && \
  pip install --upgrade -r requirements.txt && \
  pip install --no-cache-dir bitsandbytes

# additional install
ARG DEBIAN_FRONTEND=noninteractive
USER root
RUN apt install -y gcc-10 g++-10

USER $USERNAME

# build xformers==0.0.14.dev0
# https://github.com/facebookresearch/xformers/issues/650
# https://github.com/facebookresearch/xformers/commit/1d31a3ac3b11f40fde7f00aa64debb0fd4d6f376
# https://github.com/AUTOMATIC1111/stable-diffusion-webui/discussions/3525#discussioncomment-3965024
#ENV FORCE_CUDA="1"
#ENV TORCH_CUDA_ARCH_LIST="8.6"
#RUN source activate conda && \
#  pip install ninja \
#  pip install -v -U git+https://github.com/facebookresearch/xformers.git@faa88b123514562dbe8e32ec72a25937b0dd9da5#egg=xformers

RUN source activate conda && \
  pip install -v -U xformers==0.0.17

# install triton
# https://github.com/P2Enjoy/kohya_ss-docker/blob/736c0116b00904e700f3bad825a19c873f1a85be/docker-compose.yml
RUN source activate conda && \
  pip install triton==2.0.0

# TODO: TensorRT

# additional install
ARG DEBIAN_FRONTEND=noninteractive
USER root
RUN apt install -y libgl1 gnupg2 moreutils git tk libglib2.0-0 libaio-dev

USER $USERNAME

# entrypoint
WORKDIR /app/sd-scripts
COPY --chown=$USERNAME train.entry.sh .
RUN chmod +x train.entry.sh

ENTRYPOINT ["/bin/bash", "-c", "./train.entry.sh"]
