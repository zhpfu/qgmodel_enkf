#!/bin/bash
export CONFIG=/glade/p/work/mying/qgmodel_enkf/config/ctrl/noda
. $CONFIG

nkx=`echo "$kmax*2+1" |bc`
nky=`echo "$kmax+1" |bc`
nx=`echo "($kmax+1)*2" |bc`
ny=$nx

obsdir=$workdir/obs

mkdir -p $obsdir
rm -f $obsdir/*

n=20  #batch of obs run in matlab job
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

  r=${err_slope:- 1};
  [kx,ky]=ndgrid(-$kmax:$kmax,0:$kmax);
  kk=sqrt(kx.^2+ky.^2);
  noise=(kk.^((r-1)/2)).*exp(2*pi*sqrt(-1)*rand(2*$kmax+1,$kmax+1));
  norm=sum(sum(noise.*conj(noise)))*2;
  noise=$obs_err*noise/sqrt(norm);
  uk(:,:,1)=uk(:,:,1)+noise;
  noise=(kk.^((r-1)/2)).*exp(2*pi*sqrt(-1)*rand(2*$kmax+1,$kmax+1));
  norm=sum(sum(noise.*conj(noise)))*2;
  noise=$obs_err*noise/sqrt(norm);
  vk(:,:,1)=vk(:,:,1)+noise;

  u=spec2grid(uk); v=spec2grid(vk);
  zetak=uv2zeta(uk,vk); zeta=spec2grid(zetak);
  psik=zeta2psi(zetak); psi=spec2grid(psik);
  tempk=psi2temp(psik); temp=spec2grid(tempk);
  uv_err=sqrt(mean(mean(0.5*((u(:,:,1)-u0(:,:,1)).^2+(v(:,:,1)-v0(:,:,1)).^2),1),2));
  zeta_err=sqrt(mean(mean((zeta(:,:,1)-zeta0(:,:,1)).^2,1),2));
  psi_err=sqrt(mean(mean((psi(:,:,1)-psi0(:,:,1)).^2,1),2));
  temp_err=sqrt(mean(mean((temp(:,:,1)-temp0(:,:,1)).^2,1),2));

  system(['echo ' num2str(uv_err) ' >> $obsdir/uv_err']);
  system(['echo ' num2str(temp_err) ' >> $obsdir/temp_err']);
  system(['echo ' num2str(psi_err) ' >> $obsdir/psi_err']);
  system(['echo ' num2str(zeta_err) ' >> $obsdir/zeta_err']);

  f=fopen(['$obsdir/' sprintf('%5.5i',n)],'w');
  for z=1
  for y=1:$obs_thin:$ny
  for x=1:$obs_thin:$nx
    fprintf(f,'%7.2f %7.2f %5.2f %12.5f %12.5f %12.5f %12.5f %12.5f \n',x,y,z,...
           u(x,y,z),v(x,y,z),psi(x,y,z),zeta(x,y,z),temp(x,y,z));
  end 
  end 
  end
  fclose(f);
end

EOF

$ml matlab_script.$id # > /dev/null
rm matlab_script.$id

done
