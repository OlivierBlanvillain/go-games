#!/bin/sh

set -eux

read -r -p "Review "$@"? [y/N] " response
case $response in
  [yY]) ;;
  *) exit 1;;
esac

game=$(cat "$@"      | base64 -w 0)
runs=$(cat run.sh    | sed s/##/"$game"/g | base64 -w 0)
conf=$(cat spot.json | sed s/##/"$runs"/g)
spec=$(mktemp)

echo "$conf" > "$spec"

aws ec2 request-spot-instances
  --spot-price 0.5
  --instance-count 1
  --launch-specification "file://$spec"
