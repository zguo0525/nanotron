#!/bin/bash
export PYTHONFAULTHANDLER=1
export OMP_NUM_THREADS=32
source /dccstor/mit_fm/zguo0525/codemamba/src/nanotron/examples/ccc/ccc_nccl.sh

# Simple script to create a tiny mamba model and train it

set -e -x

export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:2048
# export TORCH_DISTRIBUTED_DEBUG=DETAIL
# export RANK=$((LSF_PM_XTASKID - 1))
export MASTER_ADDR=$(echo ${LSB_MCPU_HOSTS} | tr ' ' '\n' | head -n 1)
export MASTER_PORT=54967
echo "Distributed training:"
echo MASTER_ADDR $MASTER_ADDR
echo MASTER_PORT $MASTER_PORT

# Create the YAML config file

EXAMPLE_PATH=$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)
REPO_PATH=$(dirname $EXAMPLE_PATH)
python $EXAMPLE_PATH/create_config_mamba.py

# Setup from environment variables

export CUDA_DEVICE_MAX_CONNECTIONS=1
export FI_PROVIDER="efa"

# Start the GPU monitor in the background
(while :; do nvidia-smi; sleep 100; done) &

# Train the model
nvidia-smi
MKL_SERVICE_FORCE_INTEL=1
torchrun \
    --nproc_per_node 8 \
    --nnodes=$WORLD_SIZE:$WORLD_SIZE \
    --rdzv_backend c10d \
    --rdzv_endpoint=$MASTER_ADDR:$MASTER_PORT \
    --max_restarts 0 \
    --tee 3 \
    $REPO_PATH/mamba/train_mamba.py --config-file $EXAMPLE_PATH/config_mamba.yaml
