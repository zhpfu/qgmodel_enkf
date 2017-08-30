#!/bin/bash
#add spectral perturbation in k1:k2 with random phase
. $CONFIG

infile=$1
outfile=$2
k1=$3
k2=$4
amp_faction=$5

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

psi=spec2grid(psik);
[w p]=pwrspec2d(psi);

[kx,ky]=ndgrid(-$kmax:$kmax,0:$kmax); kk=sqrt(kx.^2+ky.^2);

for z=1:$nz
  psikz=psik(:,:,z);
  for k=$k1:$k2
	  ind=(kk>=k & kk<k+1);
  	psikz(ind)=psikz(ind)+$amp_faction*sqrt(p(k+1)/sum(ind(:)))*exp(2*sqrt(-1)*pi*phase(ind));
  end
  psik(:,:,z)=psikz;
end
write_field(psik,'$outfile',1);
EOF

$ml matlab_script.$id > /dev/null
rm matlab_script.$id
