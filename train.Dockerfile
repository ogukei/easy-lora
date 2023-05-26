
# step 1
FROM continuumio/miniconda3:latest AS compile-image

ENV PYTHON_VERSION=3.10
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y curl git wget software-properties-common

# conda
RUN conda create --name conda python=${PYTHON_VERSION} pip
RUN python3 -m pip install --no-cache-dir --upgrade pip

# step 2
FROM nvidia/cuda:11.6.2-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive
# user
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# root
RUN apt-get update && \
    apt-get install -y curl git wget software-properties-common && \
    apt-get install -y libgl1 gnupg2 moreutils tk libglib2.0-0 libaio-dev

# create user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
# set user
USER $USERNAME

COPY --from=compile-image --chown=$USERNAME /opt/conda /opt/conda
ENV PATH /opt/conda/bin:$PATH
ENV HF_HOME=/home/$USERNAME/.cache/huggingface

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
  pip install --no-cache-dir xformers==0.0.17

# install triton
# https://github.com/P2Enjoy/kohya_ss-docker/blob/736c0116b00904e700f3bad825a19c873f1a85be/docker-compose.yml
RUN source activate conda && \
  pip install triton==2.0.0

# entrypoint
WORKDIR /app/sd-scripts
COPY --chown=$USERNAME train.entry.sh .
RUN chmod +x train.entry.sh

ENTRYPOINT ["/bin/bash", "-c", "./train.entry.sh"]
