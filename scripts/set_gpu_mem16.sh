#!/usr/bin/env bash

echo "
# set gpu memory split to minimum value
gpu_mem=16" | tee -a /boot/config.txt
