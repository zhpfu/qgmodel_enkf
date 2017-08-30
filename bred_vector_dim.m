clear all

addpath /wall/s0/yxy159/qgmodel_enkf/util
addpath /wall/s0/yxy159/graphics
workdir='/wall/s0/yxy159/qgmodel_enkf/sqg';

close all

getparams([workdir '/truth']);

nens=200;
n=20;
nid=sprintf('%5.5i',n);

psik=read_field([workdir '/truth/' nid],nkx,nky,nz,1);
psi0=spec2grid(psik);

for m=1:nens
	psik=read_field([workdir '/bred_vector/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',n)],nkx,nky,nz,1);
  psi(:,:,m)=spec2grid(psik)-psi0;
end

del=120;
%k1=[1:10 20:10:120];

%for k=1:length(k1)-1
  for m=1:nens
    %psiout(:,:,m)=kfilter(psi(:,:,m),k1(k),k1(k+1));
    psiout(:,:,m)=psi(:,:,m);
  end

  for i=128 %:nx
  for j=128 %:ny

    for m=1:nens;
      xind=mod(i-del:i+del,nx); xind(xind==0)=nx;
      yind=mod(j-del:j+del,ny); yind(yind==0)=ny;
      tmp=psiout(xind,yind,m);
      dat(:,m)=tmp(:);
    end
    [v d]=eig(dat'*dat);

    %bvdim(i,j,k)=sum(sqrt(abs(diag(d))))^2/sum(diag(d));
    bvdim=sum(sqrt(abs(diag(d))))^2/sum(diag(d))

  end
  end
  %save(['bvdim_k'],'bvdim','-v7.3');
%end


%contourf(bvdim','linestyle','none'); colorbar
%axis equal; axis([1 nx 1 ny])

%saveas(gca,'~/html/1','pdf')
