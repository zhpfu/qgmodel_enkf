#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J run_cycle 
#BSUB -W 2:00
#BSUB -q small 
#BSUB -n 32
#BSUB -R "span[ptile=16]"
#BSUB -o log
source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

export CONFIG=/glade/p/work/mying/qgmodel_enkf/config/ctrl/sl64
. $CONFIG

mkdir -p $workdir/$casename
cd $workdir/$casename

#first guess is truth+perturbation
#$homedir/add_perturb.sh initial_condition first_guess 3 10 0.8

#get initial prior ensemble from noda case
if [ ! -f current_cycle ]; then
	for m in `seq 1 $nens`; do
		mid=`printf %4.4i $m`
		mkdir -p $mid
		cp $workdir/noda/$mid/f_`printf %5.5i $((spinup_cycle+1))`.bin $mid/.
	done 
	echo $((spinup_cycle+1)) > current_cycle
fi

current_cycle=`cat current_cycle`

for n in `seq $current_cycle $num_cycle`; do
echo $n
  if $run_enkf && [ $n -gt $spinup_cycle ] && [ $(((n+$obs_interval-1)%$obs_interval)) -eq 0 ]; then 
		$homedir/enkf.sh $n
		for m in `seq 1 $nens`; do 
			mem=`printf %4.4i $m`
			if [ ! -f $mem/`printf %5.5i $n`.bin ]; then 
        echo "enkf failed at cycle $n $mem/`printf %5.5i $n`.bin"; exit;
      fi
		done
  else
    nt=16; t=0;
		for m in `seq 1 $nens`; do 
			mem=`printf %4.4i $m`
      cd $mem
      ln -fs f_`printf %5.5i $n`.bin `printf %5.5i $n`.bin &
      t=$((t+1))
      if [ $t -gt $nt ]; then t=0; wait; fi
      cd ..
    done
  fi

	ntask=${LSB_DJOB_NUMPROC:-1}
  nm=`echo "($nens+$ntask-1)/$ntask" |bc`
  ntask=`echo "$nens/$nm" |bc`
  for task in `seq 1 $ntask`; do
    m1=`echo "($task-1)*$nm+1" |bc`
    m2=`echo "$task*$nm" |bc`
    if [ $m2 -gt $nens ]; then m2=$nens; fi
		cat $LSB_DJOB_HOSTFILE |head -n $((task+1)) |tail -n1 > nodefile.`printf %4.4i $task`
    cat > run_qg.`printf %4.4i $task` << EOF
#!/bin/bash
for m in \$(seq $m1 $m2); do 
  cd \$(printf %4.4i \$m)
  rm -f output.bin
  cp -L `printf %5.5i $n`.bin input.bin
  for i in 3 10; do
    rm -f restart.nml
    $homedir/namelist_input.sh 0 \$i > input.nml
    $codedir/$qgexe >& /dev/null
    if [ -f output.bin ]; then break; fi
  done
  mv output.bin f_`printf %5.5i $((n+1))`.bin
  cd ..
done
EOF
    chmod 755 run_qg.`printf %4.4i $task`
		blaunch -u nodefile.`printf %4.4i $task` ./run_qg.`printf %4.4i $task` &
  done
	wait

  for m in `seq 1 $nens`; do 
  	mem=`printf %4.4i $m`
		if [ ! -f $mem/f_`printf %5.5i $((n+1))`.bin ]; then 
      echo "enkf failed at cycle $n $mem/`printf %5.5i $((n+1))`.bin"; exit; 
    fi
	done

	echo $((n+1)) > current_cycle
done
