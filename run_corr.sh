#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J run_cycle 
#BSUB -W 2:00
#BSUB -q small
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

nens=32
expname=ctrl
casename=noda

matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; expname='$expname'; casename='$casename'; corr_map; exit" 

