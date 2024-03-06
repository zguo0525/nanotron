export WORLD_SIZE=1
export NUM_GPU=1

export TIMESTAMP=$( date +%Y-%m-%d_%H-%M-%S )

for i in {1..1}
do
	bsub -q alt_7d -K -M 1024G -gpu "num=$NUM_GPU/task:mode=exclusive_process" -n $WORLD_SIZE  \
		-R "select[infiniband && h100 && hname!=cccxc712 && hname!=cccxc713 && hname!=cccxc714] rusage[mem=1024G]" \
		-o distributed-${TIMESTAMP}.log \
		blaunch.sh bash -c "WORLD_SIZE=$WORLD_SIZE NUM_GPU=$NUM_GPU ./train_mamba.sh"
done