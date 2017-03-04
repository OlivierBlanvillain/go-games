#!/bin/sh

aws ec2 run-instances --cli-input-json file://micro.json --user-data file://run.sh
