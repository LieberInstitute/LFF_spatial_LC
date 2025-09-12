#!/bin/bash
#SBATCH --mem=20G
#SBATCH --job-name=03-create_samui
#SBATCH -o logs/samui_%a.txt
#SBATCH -e logs/samui_%a.txt
#SBATCH --array=1

#  -43%4

echo "**** Job starts ****"
date


echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${SLURM_JOBID}"
echo "Job name: ${SLURM_JOB_NAME}"
echo "Hostname: ${SLURM_NODENAME}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

donor=$(awk "NR==${SLURM_ARRAY_TASK_ID}" /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/16_samui/sample-capture-brnum_LUT.txt)
echo "Processing sample ${donor}"
date


module load samui/1.0.0-next.49
python 03-create_samui.py $donor

echo "**** Job ends ****"
date

