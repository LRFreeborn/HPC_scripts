#!/bin/bash

#SBATCH --partition=blanca
#SBATCH --qos=preemptable
#SBATCH --nodes=2
#SBATCH --ntasks=24
#SBATCH --time=00:10:00
#SBATCH --output=abaqus_%j.out

#load the abaqus module
module load abaqus

# get the example input file using abaqus fetch (comment following lines out if you're using your own input)
export JOBNAME=t5-std
abaqus fetch job=$JOBNAME

# create a scratch directory to run this job in
export SCRATCHDIR=/rc_scratch/$USER/abaqus/$SLURM_JOBID
echo $SCRATCHDIR
mkdir -p $SCRATCHDIR

# copy the input file to the scratch directory and change to it
cp $JOBNAME.inp $SCRATCHDIR
cd $SCRATCHDIR

# unset SLURM_GTIDS (necessary for parallel runs)
unset SLURM_GTIDS
export TMPDIR=/rc_scratch/$USER

# generate mp_host_list
mpi_tasks_per_node=$(bc <<< "scale=0;$SLURM_NTASKS/$SLURM_JOB_NUM_NODES")
node_list=`scontrol show hostname $SLURM_NODELIST`
echo $node_list
mp_host_list="["
for i in ${node_list} ; do
    mp_host_list="${mp_host_list}['$i',$mpi_tasks_per_node],"
done
echo $mp_host_list

# generate abaqus_v6.env
cat > abaqus_v6.env << EOF
mp_mpi_implementation=PMPI
mp_mpirun_path={PMPI: '/curc/sw/abaqus/V6R2019x/linux_a64/code/bin/SMAExternal/pmpi/bin/mpirun'}
mp_host_list=${mp_host_list}
EOF
sed -i '$s/.$/]/' abaqus_v6.env

# run Abaqus
abaqus job=$JOBNAME input=$JOBNAME cpus=$SLURM_NTASKS mp_mode=mpi interactive
