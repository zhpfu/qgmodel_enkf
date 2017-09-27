#!/bin/bash

expname=$1
casename=$2
nens=$3
obs_thin=$4
n1=$5
nt=$6
dt=1
vtype=$7

cat > tmp.sh << EOF
#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J $expname.$casename.$vtype
#BSUB -W 1:00
#BSUB -q regular 
#BSUB -n 1
#BSUB -R "span[ptile=16]"
#BSUB -o log/proc.$expname.$casename.$vtype
#BSUB -e log/proc.$expname.$casename.$vtype

source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc
matlab -nodesktop -nosplash -nodisplay -r "for i=[8 16 32 64]; nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename=['$casename' num2str(i)]; n1=$n1; nt=$nt; dt=$dt; diagnostics_$vtype; end; exit" 
EOF

bsub < tmp.sh
rm tmp.sh
#matlab -nodesktop -nosplash -nodisplay -r "nens=$nens; obs_thin=$obs_thin; expname='$expname'; casename='$casename'; n1=$n1; nt=$nt; dt=$dt; diagnostics_$vtype; exit" 
