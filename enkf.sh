#!/bin/bash
. $CONFIG

n=$1
cd $workdir/$casename

nt=16
t=0
for m in `seq 1 $nens`; do
  rm -f `printf %4.4i $m`/`printf %5.5i $n`.bin &
  t=$((t+1))
  if [ $t -gt $nt ]; then t=0; wait; fi
done
wait

cat > param.in << EOF
&enkf_param
 kmax=$kmax
 nz=$nz
 nens=$nens
 ob_thin=${obs_thin:-2}
 ob_err=${obs_err:-3}
 ob_type=${obs_type:-1,2}
 state_type=${state_type:-3}
 krange=${krange:-1}
 localize_opt=${localize:-1}
 localize_cutoff=${localize_cutoff:-16}
 find_roi=${find_roi:-1}
 inflate_adapt=${inflate_adapt:- F}
 inflate_coef=${inflate_coef:-1}
 use_aoei=${use_aoei:- F}
 relax_opt=${relax_opt:-0}
 relax_adapt=${relax_adapt:- F}
 relax_coef=${relax_coef:-0}
 debug=${debug:- T}
/
EOF

mpirun.lsf $homedir/enkf_src/enkf.exe $workdir/$casename $workdir/obs $n >> enkf.log 2>&1
