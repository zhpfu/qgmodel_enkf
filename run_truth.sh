#!/bin/bash
#BSUB -P UPSU0001
#BSUB -J run_truth
#BSUB -W 1:00
#BSUB -q small
#BSUB -n 1
#BSUB -R "span[ptile=1]"
#BSUB -o log
source /glade/u/apps/opt/lmod/4.2.1/init/bash
source ~/.bashrc

export CONFIG=/glade/p/work/mying/qgmodel_enkf/sample
. $CONFIG

mkdir -p $workdir/truth
cd $workdir/truth

if [ ! -f current_cycle ]; then
  echo 1 > current_cycle
  cp $workdir/initial_condition.bin input.bin
fi

current_cycle=`cat current_cycle`
for n in `seq $current_cycle $num_cycle`; do
  echo $n

  cp input.bin `printf %5.5i $n`.bin
  rm -f output.bin

  #each cycle step uses a different idum
	idum=$n  #truth model stochastic forcing
	#idum=`echo "(14423*$n+5324)%13431" |bc` #rand error in stoch. forcing
  $homedir/namelist_input.sh $idum > input.nml 
  ln -fs $codedir/$qgexe .
  rm -f restart.nml

  ./$qgexe >& /dev/null

  if [ ! -f output.bin ]; then 
    echo 'abort'
    exit
  fi
  mv output.bin input.bin
  
  echo $((n+1)) > current_cycle
done
