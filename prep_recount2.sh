#!/bin/sh
set -e
wget -O recount2_PLIER_data.zip https://ndownloader.figshare.com/files/10881866
unzip recount2_PLIER_data.zip
cd recount2_PLIER_data
docker pull aabaker99/cogaps:latest
docker run -it -v `pwd`:`pwd` -w `pwd` aabaker99/cogaps:latest Rscript prep_recount2.R
