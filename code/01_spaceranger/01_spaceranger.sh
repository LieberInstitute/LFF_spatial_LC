#!/bin/bash
#SBATCH --mem=80G
#SBATCH -n 8
#SBATCH --job-name=lc-spaceranger
#SBATCH -o logs/spaceranger_slurm_231013o.txt
#SBATCH -e logs/spaceranger_slurm_231013e.txt
#SBATCH --array=1-4

echo "**** Job starts ****"
date

echo "**** JHPCE info ****"
echo "User: ${USER}"
echo "Job id: ${SLURM_JOBID}"
echo "Job name: ${SLURM_JOB_NAME}"
echo "Hostname: ${SLURM_NODENAME}"
echo "Task id: ${SLURM_ARRAY_TASK_ID}"

## load SpaceRanger
module load spaceranger/2.1.0

## List current modules for reproducibility
module list

## Locate file
SAMPLE=$(awk "NR==${SLURM_ARRAY_TASK_ID}" sample_list.txt)
echo "Processing sample ${SAMPLE}"
date

## Get slide and area
SLIDE=$(echo ${SAMPLE} | cut -d "_" -f 1)
CAPTUREAREA=$(echo ${SAMPLE} | cut -d "_" -f 2)
SAM=$(paste <(echo ${SLIDE}) <(echo "-") <(echo ${CAPTUREAREA}) -d '')
echo "Slide: ${SLIDE}, capture area: ${CAPTUREAREA}"

## Find FASTQ file path
FASTQPATH=$(ls -d /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/raw-data/01_debug-FASTQ/${SAMPLE}/)

## Hank from 10x Genomics recommended setting this environment
export NUMBA_NUM_THREADS=1

## Run SpaceRanger
spaceranger count \
    --id=${SAMPLE} \
    --transcriptome=/dcs04/lieber/lcolladotor/annotationFiles_LIBD001/10x/refdata-gex-GRCh38-2020-A \
    --fastqs=${FASTQPATH}\
    --image=/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/VistoSeg/${SAMPLE}.tif \
    --slide=${SLIDE} \
    --area=${CAPTUREAREA} \
    --loupe-alignment=/dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/Images/loupe-alignment/${SAM}.json \
    --jobmode=local \
    --localcores=8 \
    --localmem=64

## Move output
echo "Moving results to new location"
date
mkdir -p /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/03_debug_spaceranger/
mv ${SAMPLE} /dcs05/lieber/marmaypag/LFF_spatialLC_LIBD4140/LFF_spatial_LC/processed-data/03_debug_spaceranger/

echo "**** Job ends ****"
date

