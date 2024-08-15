#!/bin/bash
#SBATCH -p shared
#SBATCH --mem=650G
#SBATCH --job-name=nullresid_hdf5array
#SBATCH --ntasks-per-node=1
#SBATCH -o /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/06_FeatSelection_Dimred_Harmony/03-logs/03a-hdf5arraynullresid.out
#SBATCH -e /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/06_FeatSelection_Dimred_Harmony/03-logs/03a-hdf5nullresid.err


# this script must be run from code/06_

set -e

echo "**** Job starts ****"
date

echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${SLURM_JOB_ID}"
echo "Job name: ${SLURM_JOB_NAME}"
echo "Node name: ${SLURMD_NODENAME}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

## Load the R module
module load conda_R/4.3.x

## List current modules for reproducibility
module list

## Edit with your job command
Rscript 03a-fastapproxGLMPCA_allgene_nullresiduals_HDF5array.R

echo "**** Job ends ****"
date
