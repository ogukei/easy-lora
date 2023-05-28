#!/bin/bash

IMAGES_DIR=/workspace/images

# from https://zunko.jp/con_illust.html
ZUNKO_ZIP="https://gist.github.com/ogukei/86e362ab1262693723b266e9d9ee81ed/raw/429998645883b43165e7e8cac62115aca3fde46e/zunko.zip"

mkdir -p "$IMAGES_DIR"
wget -r -q --show-progress "$ZUNKO_ZIP" -O zunko.zip

# validate
DOWNLOADED_MD5=($(md5sum zunko.zip))
if [ $DOWNLOADED_MD5 == '4209fb578c2eaf0d6f03abdf451493a7' ]; then
  # unzip and copy
  unzip zunko.zip
  cp zunko/* "$IMAGES_DIR"
  echo 'Successfully downloaded the Zunko images to `images/*`'
else
  echo 'Failed to download the images'
fi
