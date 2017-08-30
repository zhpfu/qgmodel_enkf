#!/bin/bash
. $CONFIG
idum=$1
dtfac=${2:-1}

cat << EOF
&run_params
 kmax = $kmax
 nz = $nz

 F = ${F:-0.}
 beta = ${beta:-0.}

 adapt_dt = F
 dt = `echo "$dt/$dtfac" |bc -l`

 psi_init_type = 'read'
 psi_init_file = 'input'
 initialize_energy = F

 strat_type = '${strat_type:-linear}'
 ubar_type = '${ubar_type:-linear}'
 uscale = ${uscale:-0.1}

 use_forcing = ${use_forcing:-F}
 norm_forcing = ${norm_forcing:-F}
 forc_coef = ${forc_coef:-0}
 forc_corr = ${forc_corr:-0}
 kf_min = ${kf_min:-1}
 kf_max = ${kf_max:-3}

 filter_type = '${filter_type:-hyperviscous}'
 filter_exp = ${filter_exp:-4}
 filt_tune = ${filt_tune:-1}
 k_cut = ${k_cut:-10}

 bot_drag = ${bot_drag:-0}
 therm_drag = ${therm_drag:-0} 

 idum = $idum

 total_counts = `echo "$frame_per_cycle*$dtfac" |bc`
 write_step = `echo "$frame_per_cycle*$dtfac" |bc`
 diag1_step = `echo "$frame_per_cycle*$dtfac" |bc`
 diag2_step = `echo "$frame_per_cycle*$dtfac" |bc`
 /
EOF
