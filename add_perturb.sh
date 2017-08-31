#!/bin/bash
#add spectral perturbation in k1:k2 with random phase
. $CONFIG

infile=$1
outfile=$2
amp=$3
slope=$4

nkx=`echo "$kmax*2+1" |bc`
nky=`echo "$kmax+1" |bc`
nx=`echo "($kmax+1)*2" |bc`
ny=$nx

id=$RANDOM
rm -f $outfile.bin

cat > matlab_script.$id << EOF
addpath '$homedir/util';
rng('shuffle');
pi=4.0*atan(1.0);
psik=read_field('$infile',$nkx,$nky,$nz,1);
phase=rand($nkx,$nky);
[kx,ky]=ndgrid(-$kmax:$kmax,0:$kmax); kk=sqrt(kx.^2+ky.^2); kk(kk==0)=0.01;
noise=$amp*(kk.^(($slope-1)/2)).*exp(2*sqrt(-1)*pi*phase);
for z=1:$nz
  psik(:,:,z)=psik(:,:,z)+noise;
end
write_field(psik,'$outfile',1);
EOF

$ml matlab_script.$id > /dev/null
rm matlab_script.$id
