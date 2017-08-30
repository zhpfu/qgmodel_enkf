#!/bin/bash

export CONFIG=/glade/p/work/mying/qgmodel_enkf/config/N10_thin4_se/noda
. $CONFIG

mkdir -p $workdir/$casename
cd $workdir/$casename

#first guess is truth+perturbation
#$homedir/add_perturb.sh initial_condition first_guess 3 10 0.8

#perturb ic
if [ ! -f current_cycle ]; then
	for m in `seq 1 $nens`; do
		mid=`printf %4.4i $m`
		mkdir -p $mid
		cd $mid 
			cp $workdir/initial_condition.bin input.bin
			#$homedir/add_perturb.sh input perturb 5 50 0.5
			$homedir/add_perturb.sh input perturb 10 50 0.8
			#$homedir/add_gaussnoise.sh input perturb 0.01
			mv perturb.bin f_00001.bin
		cd ..
	done 
	echo 1 > current_cycle
fi