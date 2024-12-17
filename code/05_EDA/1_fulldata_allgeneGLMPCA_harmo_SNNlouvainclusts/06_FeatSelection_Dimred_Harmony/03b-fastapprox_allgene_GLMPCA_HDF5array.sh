#!/bin/bash
#SBATCH -p shared
#SBATCH --mem=650G
#SBATCH --job-name=glmpca_hdf5array
#SBATCH --ntasks-per-node=5
#SBATCH -o /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/06_FeatSelection_Dimred_Harmony/03-logs/03b-allgeneGLMPCA.out
#SBATCH -e /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/06_FeatSelection_Dimred_Harmony/03-logs/03b-allgeneGLMPCA.err


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

Rscript 03b-fastapprox_allgene_GLMPCA_HDF5array.R

echo "**** Job ends ****"
date

## List of all modules at runtime
module list
