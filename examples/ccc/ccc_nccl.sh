#!/bin/bash
# Fix infiniband
IB_NAME=$(echo $(ibv_devinfo | grep -B17 Ethernet | grep hca_id | cut -f2 -d:))
IB_PORT=$(echo $(ibv_devinfo | grep -B17 Ethernet | grep "\sport:" | cut -f2 -d":"))
export NCCL_IB_HCA="^${IB_NAME}:${IB_PORT}"
# export NCCL_IB_HCA="^mlx5_bond_0:1"
# export NCCL_DEBUG=INFO
export NCCL_SOCKET_IFNAME="ib,bond"
export NCCL_IB_CUDA_SUPPORT=1
# echo $NCCL_IB_HCA