#!/bin/bash
#SBATCH -n 1
#SBATCH --mem=5G
#SBATCH -J nochange
#SBATCH -o logs/nc.out #standard out goes here
#SBATCH -e logs/nc.err #standard error goes here
#SBATCH --array=1-14

ml conda_R/4.4.x
img=$( sed -n ${SLURM_ARRAY_TASK_ID}p ncin.txt)
ofile=$( sed -n ${SLURM_ARRAY_TASK_ID}p ncout.txt)

cp /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/${img} /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/16_samui/rot_vis_tifs_1029/${ofile}
