#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --mem=100g
#SBATCH --job-name=<your job name>
#SBATCH --time=00:15:00
#SBATCH --partition=blanca-curc  
#SBATCH --qos=preemptable
#SBATCH --output=<your job name>_%j.out
#SBATCH --error=<your job name>_%j.err
#SBATCH --mail-user=<your email address>
#SBATCH --mail-type=ALL

cd /projects/$USER/abaqus/ #change as needed; abaqus will write output files to this directory

#load modules
module load abaqus/V6R2019x

#set environment variables
unset SLURM_GTIDS
export TMPDIR=/rc_scratch/$USER

#specify input file
INPUT_FILE=/projects/$USER/abaqus_test/input_files/<your input file>.inp

abaqus job=<informative job name> inp=${INPUT_FILE} scratch=$TMPDIR memory="100gb" interactive
