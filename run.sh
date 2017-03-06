#!/bin/sh

set -eux

echo "##" | base64 -d > game.sgf

sudo su
shutdown +175 &

# Install GPU Drivers
apt update
apt install -y nvidia-opencl-icd-352
nvidia-smi -pm 1
nvidia-smi --auto-boost-default=0
nvidia-smi -ac 2505,875

# Install sgftools
apt install -y mercurial python-numpy
hg clone https://bitbucket.org/OlivierBlanvillain/sgftools
(cd sgftools; python setup.py build install)

# Install Leela
apt install -y wget mailutils unzip
wget https://www.sjeng.org/dl/Leela090GTP.zip
unzip Leela090GTP.zip
chmod a+x leela_090_linux_x64_opencl

# Lunch the review
python sgftools/scripts/sgfanalyze -n 300 -x ./leela_090_linux_x64_opencl game.sgf > review.sgf

# Email result
echo | mail -aFrom:Leela@aws -s "Game review" -A review.sgf olivier.blanvillain@gmail.com
