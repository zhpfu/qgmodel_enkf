#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J process
#BSUB -W 4:00
#BSUB -q regular
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log/

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

nens=128
expname=assimT_N$nens
obs_thin=3
n1=$1
nt=$2
dt=1
vtype=u

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

for l in 8 12 16 24 32 48 64; do
  casename=sl$l
  matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename='$casename'; n1=$n1; nt=$nt; dt=$dt; diagnostics_$vtype; exit" 
done
