#!/bin/bash
#SBATCH -n 1
#SBATCH --mem=30G
#SBATCH -J step2
#SBATCH -o logs/step2.out #standard out goes here
#SBATCH -e logs/step2.err #standard error goes here
#SBATCH --array=1-6

ml conda_R/4.4.x
img=$( sed -n ${SLURM_ARRAY_TASK_ID}p step2in.txt)
ofile=$( sed -n ${SLURM_ARRAY_TASK_ID}p step2out.txt)
flipflop=$( sed -n ${SLURM_ARRAY_TASK_ID}p step2mirtype.txt)

# pass the step 1 transformation in, apply second step and overwrite
magick convert /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/16_samui/rot_vis_tifs_1029/${img} -${flipflop} /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/16_samui/rot_vis_tifs_1029/${ofile}
