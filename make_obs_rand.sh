#!/bin/bash
export CONFIG=/wall/s0/yxy159/qgmodel_enkf/config/qg1/noda
. $CONFIG

nkx=`echo "$kmax*2+1" |bc`
nky=`echo "$kmax+1" |bc`
nx=`echo "($kmax+1)*2" |bc`
ny=$nx

obsdir=$workdir/obs_psi

mkdir -p $obsdir
rm -f $obsdir/*

id=$RANDOM

cat > matlab_script.$id << EOF
addpath '$homedir/util';
lv=2;
for n=1:$num_cycle
  psik=read_field(['$workdir/truth/' sprintf('%5.5i',n)],$nkx,$nky,$nz,1);
	temp=spec2grid(psi2temp(psik));
  psi=spec2grid(psik);
  obs=psi(:,:,lv)+$obs_err*randn($nx,$ny);
  [x0 y0]=ndgrid(1:$nx,1:$ny);
  f=fopen(['$obsdir/' sprintf('%5.5i',n)],'w');
  nobs=2000;
  xr=rand(1,nobs)*($nx-1)+1;
  yr=rand(1,nobs)*($ny-1)+1;
  for z=lv
  for i=1:nobs
    x=xr(i); y=yr(i);
    fprintf(f,'% 6.2f % 6.2f %3i %12.5f %12.5f\n',x,y,z,$obs_err,interpn(x0,y0,obs,x,y));
  end
  end
  fclose(f);
  obsout(:,:,n)=obs;
end
addpath '$homedir/../graphics';
nc_write('$obsdir/obs.nc','obs',{'x','y','t'},obsout);
EOF

$ml matlab_script.$id # > /dev/null
rm matlab_script.$id
