#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J backup
#BSUB -W 5:00
#BSUB -q regular
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

casename=sl64
cd /glade/scratch_old/mying/qgmodel_enkf/N1000
tar czvf /glade/scratch/mying/$casename.tar.gz $casename
