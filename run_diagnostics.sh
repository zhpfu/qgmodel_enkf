#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J process 
#BSUB -W 0:10
#BSUB -q small
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

nens=32
obs_thin=1
expname=ctrl
casename=sl16
n1=1
nt=200

#matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename='$casename'; n1=$n1; nt=$nt; diagnostics; exit" 
matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename='noda'; n1=$n1; nt=$nt; diagnostics_ref; exit" 

