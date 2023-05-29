
# Easy LoRA

Provides an easy-to-use LoRA training tool by dockerized [kohya-ss/sd-scripts](https://github.com/kohya-ss/sd-scripts).

An example of LoRA output |
:-:|
![example](https://gist.githubusercontent.com/ogukei/07c3262baee88c3214e4d272289ef3e2/raw/a5e341e79285473c4c75eeb8ce40fd22d7a99d2f/example.png) |

## Requirements

* Linux (such as Ubuntu 22.04 LTS) or Windows
* NVIDIA Container Toolkit
    * https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#installing-on-ubuntu-and-debian
* CUDA compatible GPU

## Quickstart

Produces the LoRA model that generates anime-style illustrations of [Tohoku Zunko](https://zunko.jp/).

```
docker compose build train
docker compose run download_images
docker compose run train gsdf/Counterfeit-V2.5 zunko

# output/zunko.safetensors will be generated
```

## Generate Images Using LoRA

### AUTOMATIC1111

#### Install

```
git clone https://github.com/AbdBarho/stable-diffusion-webui-docker
cd stable-diffusion-webui-docker
git reset --hard 1df18b803cda07309507088128c7ab999d04de63
docker compose --profile download up --build
docker compose --profile auto up --build
```

#### Usage

1. Copy the trained `<this-repository>/output/zunko.safetensors` to the `data/Lora` directory
1. Download `Counterfeit-V2.5_fp16.safetensors` via [gsdf/Counterfeit-V2.5](https://huggingface.co/gsdf/Counterfeit-V2.5/tree/main) and put it in the `data/StableDiffusion` directory
1. Download `EasyNegative.safetensors` via [gsdf/EasyNegative](https://huggingface.co/datasets/gsdf/EasyNegative/tree/main) and put it in the `data/embeddings` directory
1. Access `http://localhost:7860/` with Chrome and open the AUTOMATIC1111 UI
1. Select the base model `Counterfeit-V2.5_fp16.safetensors`
    * Stable Diffusion checkpoint
1. Move to the Settings tab
1. Select the VAE `vae-ft-mse-840000-ema-pruned.ckpt`
    * Settings > Stable Diffusion > SD VAE
1. Apply settings
1. Move to the txt2img tab
1. Restart the Docker container
    * Enter Ctrl+C to terminate the console
1. Enter the prompt below
    * `(best quality, masterpiece:1.2), zunko, 1girl, <lora:zunko:1>`
1. Enter the negative prompt below
    * `(EasyNegative:1)`
1. Generate

<details>
<summary>Prompt to generate the example image in this README.md</summary>

```
(best quality, masterpiece:1.2), zunko, 1girl, <lora:zunko:1>
Negative prompt: (EasyNegative:1)
Steps: 20, Sampler: Euler a, CFG scale: 7, Seed: 765595793, Size: 512x512, Model hash: 71e703a0fc, Model: Counterfeit-V2.5_fp16, Denoising strength: 0.7, Version: v1.2.1, Hires upscale: 2, Hires upscaler: Latent

Used embeddings: EasyNegative [119b]
```
</details>

## Notice

* The images of Tohoku Zunko are provided as the guideline below
    * https://zunko.jp/guideline.html

## Links

* kohya-ss/sd-scripts setup tutorial video (in Japanese)
    * https://www.youtube.com/watch?v=N1tXVR9lplM
