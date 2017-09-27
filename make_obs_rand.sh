#!/bin/bash
export CONFIG=/glade/p/work/mying/qgmodel_enkf/config/$1/noda
. $CONFIG

nkx=`echo "$kmax*2+1" |bc`
nky=`echo "$kmax+1" |bc`
nx=`echo "($kmax+1)*2" |bc`
ny=$nx

obsdir=$workdir/obs_rand

mkdir -p $obsdir
rm -f $obsdir/*

n=5  #batch of obs run in matlab job
for i in `seq 1 $n`; do

nn=`echo "$num_cycle/$n" |bc`
n1=`echo "($i-1)*$nn+1" |bc`
n2=`echo "$i*$nn" |bc`

id=$RANDOM

cat > matlab_script.$id << EOF
addpath '$homedir/util';
rng('shuffle');

for n=$n1:$n2
  psik=read_field(['$workdir/truth/' sprintf('%5.5i',n)],$nkx,$nky,$nz,1);
  psi0=spec2grid(psik);
  uk=psi2u(psik); vk=psi2v(psik);
  u0=spec2grid(uk); v0=spec2grid(vk);
  zeta0=spec2grid(psi2zeta(psik));
  temp0=spec2grid(psi2temp(psik));

  [x y z]=ndgrid(1:$nx,1:$ny,1:$nz);
  nobs=ceil($nx/$obs_thin)*ceil($ny/$obs_thin);
  xo=rand(1,nobs)*($nx-1)+1;
  yo=rand(1,nobs)*($ny-1)+1;
  zo=ones(1,nobs);
  uv_err=$obs_err; temp_err=$obs_err; psi_err=0.2; zeta_err=230;
 
  u=interpn(x,y,z,u0,xo,yo,zo)+randn(1,nobs)*uv_err;
  v=interpn(x,y,z,v0,xo,yo,zo)+randn(1,nobs)*uv_err;
  psi=interpn(x,y,z,psi0,xo,yo,zo)+randn(1,nobs)*psi_err;
  zeta=interpn(x,y,z,zeta0,xo,yo,zo)+randn(1,nobs)*zeta_err;
  temp=interpn(x,y,z,temp0,xo,yo,zo)+randn(1,nobs)*temp_err;

  f=fopen(['$obsdir/' sprintf('%5.5i',n)],'w');
  for i=1:nobs
    fprintf(f,'%7.2f %7.2f %5.2f %12.5f %12.5f %12.5f %12.5f %12.5f \n',xo(i),yo(i),zo(i),...
           u(i),v(i),psi(i),zeta(i),temp(i));
  end
  fclose(f);
end

EOF

$ml matlab_script.$id # > /dev/null
rm matlab_script.$id

done
