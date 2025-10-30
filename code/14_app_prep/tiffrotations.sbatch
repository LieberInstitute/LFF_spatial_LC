#!/bin/bash
#SBATCH -n 1
#SBATCH --mem=30G
#SBATCH -J rot
#SBATCH -o logs/rot.out #standard out goes here
#SBATCH -e logs/rot.err #standard error goes here
#SBATCH --array=1-39

ml conda_R/4.4.x
img=$( sed -n ${SLURM_ARRAY_TASK_ID}p rotin.txt)
ofile=$( sed -n ${SLURM_ARRAY_TASK_ID}p rotout.txt)
deg=$( sed -n ${SLURM_ARRAY_TASK_ID}p rotdeg.txt)

magick convert /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/${img} -rotate ${deg} /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/16_samui/rot_vis_tifs_1029/${ofile}
