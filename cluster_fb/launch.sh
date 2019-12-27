#!/usr/bin/env bash

export BUCKOUT=/data/users/${USER}/fbsource/fbcode/buck-out
buck build \
  @mode/opt \
  //vision/fair/slowfast/...

FOLDER="Kinetics"
SETTING="SLOWFAST_4x16_R50"
POSTFIX="benchmark"

fry flow-gpu --name ${SETTING}_${POSTFIX} \
  --flow-entitlement gpu_fair \
  --resources '{"gpu": 8, "cpu_core": 48, "ram_gb": 200, "capabilities":["GPU_P100_HOST"]}' \
  --environment "{\"PYTHONUNBUFFERED\": \"True\"}" \
  --copy-file configs/${FOLDER}/${SETTING}.yaml configs/ \
  --copy-file cluster_fb/launch.sh ./ \
  --binary-type local \
  --disable-source-snapshot true \
  --retry 10 \
  -- \
  "${BUCKOUT}"/opt/gen/vision/fair/slowfast/tools/run_net_xar/run_net.xar \
  --cfg configs/${SETTING}.yaml \
  DATA.PATH_TO_DATA_DIR /mnt/vol/gfsai-east/ai-group/users/haoqifan/kinetics/alllist/py_slowfast \
