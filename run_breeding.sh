#!/bin/bash
export CONFIG=/wall/s0/yxy159/qgmodel_enkf/config/sqg
. $CONFIG

mkdir -p $workdir/bred_vector
cd $workdir/bred_vector

#perturb ic
if [ ! -f current_cycle ]; then
	for m in `seq 51 $nens`; do
		mid=`printf %4.4i $m`
		mkdir -p $mid
		cd $mid 
			cp $workdir/initial_condition.bin input.bin
			$homedir/add_perturb.sh input perturb 20 100 1
			mv perturb.bin f_00001.bin
		cd ..    
	done 
  echo 1 > current_cycle
fi


current_cycle=`cat current_cycle`

for n in `seq $current_cycle $num_cycle`; do
  nid=`printf %5.5i $n`
echo $nid

  for m in `seq 51 $nens`; do
    mem=`printf %4.4i $m`
    $homedir/rescale_perturb.sh $mem/f_$nid ../truth/$nid 0.0002 $mem/new
    if [ ! -f $mem/new.bin ]; then exit; fi
  done

  #run ensmeble forecast
	task=0
	ntask=7
	for m in `seq 51 $nens`; do
		mem=`printf %4.4i $m`
		cd $mem
		$homedir/namelist_input.sh $n > input.nml
    mv new.bin input.bin
    rm -f output.bin
    rm -f restart.nml
		ln -fs $codedir/$qgexe .
    ./$qgexe >& /dev/null &
		task=$((task+1))
		if [ $task == $ntask ]; then
			task=0
			wait
		fi
		cd ..
	done
	wait

	for m in `seq 51 $nens`; do
		mem=`printf %4.4i $m`
    if [ -f $mem/output.bin ]; then
      mv $mem/output.bin $mem/f_`printf %5.5i $((n+1))`.bin
    else
      exit
    fi
  done

	echo $((n+1)) > current_cycle
done
