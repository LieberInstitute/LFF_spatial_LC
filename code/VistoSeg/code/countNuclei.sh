#!/bin/bash
#SBATCH --mem=30G
#SBATCH --job-name=countNuclei
#SBATCH -o logs/countNuclei_%a.txt 
#SBATCH -e logs/countNuclei_%a.txt
#SBATCH --array=7-7%10


echo "**** Job starts ****"
date


echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${SLURM_JOBID}"s
echo "Job name: ${SLURM_JOB_NAME}"
echo "Hostname: ${SLURM_NODENAME}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

## load MATLAB
module load matlab/R2023a

## Load toolbox for VistoSeg
toolbox='/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/'

filePath=$(ls -1 /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/NMseg/*NMseg_clean.mat | sed -n "${SLURM_ARRAY_TASK_ID}p")

## Check if file path exists
if [ ! -f "$filePath" ]; then
    echo "File not found: $filePath"
    exit 1
fi

fileName=$(basename "$filePath" NMseg_clean.mat)
echo "Processing sample ${fileName}"

## Read inputs
jsonname=/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/01_spaceranger/${fileName}_untrimmed/outs/spatial/scalefactors_json.json
posname=/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/01_spaceranger/${fileName}_untrimmed/outs/spatial/tissue_positions.csv
imgname=/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/Images/${fileName}.tif

matlab -nodesktop -nosplash -nojvm -r "addpath(genpath('$toolbox')), countNuclei('$filePath','$imgname','$jsonname','$posname')" 

echo "**** Job ends ****"
date



