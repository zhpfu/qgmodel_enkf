%clear all
addpath /glade/p/work/mying/qgmodel_enkf/util
workdir='/glade/scratch/mying/qgmodel_enkf';
%expname=
%n1=1; nt=20;

getparams([workdir '/' expname '/truth']);

[x y]=ndgrid(1:nx,1:ny);
lv=1;

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut(:,:,:,n)=spec2grid(psi2u(psik));
end
[w ref]=pwrspec2d(ut);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/ref_u'],'w','ref')

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut(:,:,:,n)=spec2grid(psi2v(psik));
end
[w ref]=pwrspec2d(ut);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/ref_v'],'w','ref')

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut(:,:,:,n)=spec2grid((psik));
end
[w ref]=pwrspec2d(ut);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/ref_psi'],'w','ref')

for n=1:floor((nt-n1)/dt)+1
  nid=sprintf('%5.5i',n1+(n-1)*dt)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut(:,:,:,n)=spec2grid(psi2temp(psik));
end
[w ref]=pwrspec2d(ut);
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/ref_temp'],'w','ref')
