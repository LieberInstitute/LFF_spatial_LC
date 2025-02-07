#!/bin/bash
#SBATCH --job-name=NMseg_filt
#SBATCH --mem=40G
#SBATCH -o /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/logs/NMseg_filt.txt
#SBATCH -e /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/logs/NMseg_filt.txt

echo "**** Job starts ****"
date


echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${SLURM_JOBID}"
echo "Job name: ${SLURM_JOB_NAME}"
echo "Hostname: ${SLURM_NODENAME}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

## load MATLAB
module load matlab

matlab -nodesktop -nosplash -r "NMseg_filt"

echo "**** Job ends ****"
date