#!/bin/bash
. $CONFIG

infile=$1
controlfile=$2
pertnorm=$3
outfile=$4

nkx=`echo "$kmax*2+1" |bc`
nky=`echo "$kmax+1" |bc`
nx=`echo "($kmax+1)*2" |bc`
ny=$nx

id=$RANDOM
rm -f $outfile.bin

cat > matlab_script.$id << EOF
addpath '$homedir/util';

psik=read_field('$infile',$nkx,$nky,$nz,1);
psi1=spec2grid(psik);
psik=read_field('$controlfile',$nkx,$nky,$nz,1);
psi0=spec2grid(psik);
[w p]=pwrspec2d(psi1-psi0);
psi=sqrt($pertnorm/sum(p))*(psi1-psi0)+psi0;
psik=grid2spec(psi);
write_field(psik,'$outfile',1);
EOF

$ml matlab_script.$id > /dev/null
rm matlab_script.$id
