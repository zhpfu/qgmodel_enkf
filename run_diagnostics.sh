#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J process 
#BSUB -W 1:00
#BSUB -q small
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

nens=32
obs_thin=2
expname=ctrl
n1=51
nt=1000
dt=10
casename=sl8

#matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename='$casename'; n1=$n1; nt=$nt; dt=$dt; diagnostics; exit" 
matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename='noda'; n1=$n1; nt=$nt; dt=$dt; diagnostics_ref; exit" 

