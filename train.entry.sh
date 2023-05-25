#!/bin/bash

export BUILD_HF_HOME=$HF_HOME
export HF_HOME=/workspace/.cache/huggingface

# install default_config.yaml
mkdir -p "$HF_HOME/accelerate"
cp "$BUILD_HF_HOME/accelerate/default_config.yaml" "$HF_HOME/accelerate"

#
mkdir -p /workspace/output

export MODEL_NAME_OR_PATH=`realpath /workspace/model/*.safetensors`

source activate conda

accelerate launch --num_cpu_threads_per_process 1 train_network.py \
  --pretrained_model_name_or_path="$MODEL_NAME_OR_PATH" \
  --output_dir="/workspace/output" \
  --output_name=model \
  --dataset_config="/workspace/dataset_config.toml" \
  --train_batch_size=1 \
  --max_train_epochs=5 \
  --resolution="512,512" \
  --optimizer_type="AdamW8bit" \
  --learning_rate=1e-4 \
  --network_dim=128 \
  --network_alpha=64 \
  --enable_bucket \
  --bucket_no_upscale \
  --lr_scheduler=cosine_with_restarts \
  --lr_scheduler_num_cycles=4 \
  --lr_warmup_steps=500 \
  --keep_tokens=1 \
  --shuffle_caption \
  --caption_dropout_rate=0.05 \
  --save_model_as=safetensors \
  --clip_skip=2 \
  --seed=42 \
  --color_aug \
  --xformers \
  --mixed_precision=fp16 \
  --network_module=networks.lora \
  --persistent_data_loader_workers
