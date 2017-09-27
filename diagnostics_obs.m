%clear all
addpath /glade/p/work/mying/qgmodel_enkf/util
workdir='/glade/scratch/mying/qgmodel_enkf';
%expname=
%obs_thin=8; 
%n1=1; nt=20;

getparams([workdir '/' expname '/truth']);

[x y]=ndgrid(1:nx,1:ny);
ni=ceil(nx/obs_thin); nj=ceil(ny/obs_thin);

lv=1;

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut=spec2grid(psi2u(psik(:,:,lv)));
	a=textread([workdir '/' expname '/obs/' nid]);
	obsx=reshape(a(:,1),[ni nj]);
	obsy=reshape(a(:,2),[ni nj]); 
	obsu=reshape(a(:,4),[ni nj]);
	obsuerr(:,:,n)=obsu-interpn(x,y,ut,obsx,obsy);
end
[w1 oberr]=pwrspec2d(obsuerr);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/oberr_u'],'w1','oberr')

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut=spec2grid(psi2v(psik(:,:,lv)));
	a=textread([workdir '/' expname '/obs/' nid]);
	obsx=reshape(a(:,1),[ni nj]);
	obsy=reshape(a(:,2),[ni nj]); 
	obsu=reshape(a(:,5),[ni nj]);
	obsuerr(:,:,n)=obsu-interpn(x,y,ut,obsx,obsy);
end
[w1 oberr]=pwrspec2d(obsuerr);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/oberr_v'],'w1','oberr')

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut=spec2grid((psik(:,:,lv)));
	a=textread([workdir '/' expname '/obs/' nid]);
	obsx=reshape(a(:,1),[ni nj]);
	obsy=reshape(a(:,2),[ni nj]); 
	obsu=reshape(a(:,6),[ni nj]);
	obsuerr(:,:,n)=obsu-interpn(x,y,ut,obsx,obsy);
end
[w1 oberr]=pwrspec2d(obsuerr);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/oberr_psi'],'w1','oberr')

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut=spec2grid(psi2temp(psik(:,:,lv)));
	a=textread([workdir '/' expname '/obs/' nid]);
	obsx=reshape(a(:,1),[ni nj]);
	obsy=reshape(a(:,2),[ni nj]); 
	obsu=reshape(a(:,8),[ni nj]);
	obsuerr(:,:,n)=obsu-interpn(x,y,ut,obsx,obsy);
end
[w1 oberr]=pwrspec2d(obsuerr);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/oberr_temp'],'w1','oberr')
