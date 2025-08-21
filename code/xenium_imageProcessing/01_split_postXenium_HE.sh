#!/bin/bash
#SBATCH -p katun
#SBATCH --mem=10G
#SBATCH --job-name=countNuclei
#SBATCH -c 1
#SBATCH -t 1-00:00:00
#SBATCH -o logs/countNuclei_py_%a.txt
#SBATCH -e logs/countNuclei_py_%a.txt
#SBATCH --array=1-24%10

set -e

echo "**** Job starts ****"
date

echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${SLURM_JOB_ID}"
echo "Job name: ${SLURM_JOB_NAME}"
echo "Node name: ${HOSTNAME}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

module load visium_hd/1.0

## List current modules for reproducibility
module list

python countNuclei.py

echo "**** Job ends ****"
date

## This script was made using slurmjobs version 1.2.5
## available from http://research.libd.org/slurmjobs/
