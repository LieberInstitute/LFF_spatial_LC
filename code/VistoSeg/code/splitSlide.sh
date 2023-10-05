#!/bin/bash
#$ -cwd
#$ -l mem_free=30G,h_vmem=30G,h_fsize=100G
#$ -pe local 8
#$ -o /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/logs/$TASK_ID_splitSlide.txt
#$ -e /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/logs/$TASK_ID_splitSlide.txt
#$ -m e
#$ -M heenadivecha@gmail.com
#$ -t 9
#$ -tc 4


echo "**** Job starts ****"
date


echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${JOB_ID}"
echo "Job name: ${JOB_NAME}"
echo "Hostname: ${HOSTNAME}"
echo "Task id: ${SGE_TASK_ID}"
echo "****"
echo "Sample id: $(cat /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code/splitSlide.txt | awk '{print $NF}' | awk "NR==${SGE_TASK_ID}")"
echo "****"


## load MATLAB
module load matlab/R2019a

## Load toolbox for VistoSeg
toolbox='/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/code/VistoSeg/code'

## Read inputs from splitSlide.txt file
fname=$(awk 'BEGIN {FS="\t"} {print $1}' splitSlide.txt | awk "NR==${SGE_TASK_ID}")

## Run splitSlide function
matlab -nodesktop -nosplash -nojvm -r "addpath(genpath('$toolbox')), splitSlide('$fname',0,0,0,0)"

echo "**** Job ends ****"
date
