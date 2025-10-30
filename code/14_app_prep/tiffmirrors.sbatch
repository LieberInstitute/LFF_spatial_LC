#!/bin/bash
#SBATCH -n 1
#SBATCH --mem=30G
#SBATCH -J mirrors
#SBATCH -o logs/mirrors.out #standard out goes here
#SBATCH -e logs/mirrors.err #standard error goes here
#SBATCH --array=1-32

ml conda_R/4.4.x
img=$( sed -n ${SLURM_ARRAY_TASK_ID}p mirin.txt)
ofile=$( sed -n ${SLURM_ARRAY_TASK_ID}p mirout.txt)
flipflop=$( sed -n ${SLURM_ARRAY_TASK_ID}p mirtype.txt)

magick convert /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/${img} -${flipflop} /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/16_samui/rot_vis_tifs_1029/${ofile}
