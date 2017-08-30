#!/bin/bash
#add Gaussian white noise
. $CONFIG

infile=$1
outfile=$2
amp=$3

nkx=`echo "$kmax*2+1" |bc`
nky=`echo "$kmax+1" |bc`
nx=`echo "($kmax+1)*2" |bc`
ny=$nx

id=$RANDOM
rm -f $outfile.bin

cat > matlab_script.$id << EOF
addpath '$homedir/util';
rng('shuffle');
psik=read_field('$infile',$nkx,$nky,$nz,1);
psi=spec2grid(psik);
noise=randn($nx,$ny)*$amp;
for z=1:$nz
  psi(:,:,z)=psi(:,:,z)+noise;
end
psik=grid2spec(psi);
write_field(psik,'$outfile',1);
EOF

$ml matlab_script.$id > /dev/null
rm matlab_script.$id
