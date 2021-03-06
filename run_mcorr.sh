#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J corr 
#BSUB -W 1:00
#BSUB -q regular
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

nens=64
expname=uvN$nens
casename=forecast

matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; expname='$expname'; casename='$casename'; corr_map; exit" 

