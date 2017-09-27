#!/bin/bash
expname=$1
casename=$2
nproc=$3
localize_cutoff=$4

cat > tmp.sh << EOF
#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J $expname.$casename$localize_cutoff
#BSUB -W 0:10
#BSUB -q regular
#BSUB -n $nproc
#BSUB -R "span[ptile=16]"
#BSUB -o log/$expname.$casename$localize_cutoff
#BSUB -e log/$expname.$casename$localize_cutoff
cd /glade/p/work/mying/qgmodel_enkf
./run_cycle.sh $expname/$casename $localize_cutoff
EOF

bsub < tmp.sh
rm tmp.sh
