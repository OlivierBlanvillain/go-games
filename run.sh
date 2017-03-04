#!/bin/sh

set -eux

sudo su
yum install -y mosh && mosh-server
yum install -y tmux && tmux
shutdown +180 &

git clone https://github.com/OlivierBlanvillain/go-games.git && cd go-games
eval "$(ssh-agent -s)"
ssh-add id
ssh-keyscan -H github.com >> ~/.ssh/known_hosts
git remote set-url origin git@github.com:OlivierBlanvillain/go-games.git

# Install sgftools

yum install -y hg python-numpy
hg clone https://bitbucket.org/mkmatlock/sgftools
(cd sgftools; python26 setup.py build install)

# Install Leela

wget https://www.sjeng.org/dl/Leela090GTP.zip
unzip Leela090GTP.zip
chmod a+x leela_090_linux_x64

# Review games from latest commit

git diff --name-only HEAD~ | while read game; do
  review=reviews/$(basename $game .sgf).review.sgf
  python26 sgftools/scripts/sgfanalyze -n 300 -x leela_090_linux_x64 "$game" > "$review"
  echo | mail -s "Leela review" -a "$review" olivier.blanvillain@gmail.com
  git add "$review"
done

git commit -m "Add reviews"
git push origin master

halt
