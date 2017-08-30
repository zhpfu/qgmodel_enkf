addpath /wall/s0/yxy159/qgmodel_enkf/util
addpath /wall/s0/yxy159/qgmodel_enkf/enkf
addpath /wall/s0/yxy159/graphics
workdir='/wall/s0/yxy159/qgmodel_enkf/sqg';

getparams([workdir '/truth']);

n=35;
nid=sprintf('%5.5i',n);
nens=80;

for m=1:nens
  psik=read_field([workdir '/ensemble1/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',n)],nkx,nky,nz,1);
  psi(:,:,:,m)=spec2grid(psik);
  temp(:,:,:,m)=spec2grid(psi2temp(psik));
end
psi(:,:,:,nens+1)=mean(psi(:,:,:,1:nens),4);
temp(:,:,:,nens+1)=mean(temp(:,:,:,1:nens),4);

dat=textread([workdir '/obs/' sprintf('%5.5i',n)]);
truth=spec2grid(squeeze(read_field([workdir '/truth/' nid],nkx,nky,nz,1)));
 
prior=psi;

[x y]=ndgrid(1:nx,1:ny);
	a=textread([workdir '/obs/' nid]);
	obs_x=reshape(a(:,1),[64 64]);
	obs_y=reshape(a(:,2),[64 64]); 
	obs=reshape(a(:,5),[64 64]);

	prior_rmse=sqrt(mean(mean((mean(prior(:,:,1:nens),3)-truth).^2, 1),2));
	prior_sprd=sqrt(mean(mean(std(prior(:,:,1:nens),[],3).^2, 1),2));

  [w ref]=pwrspec2d(truth);
  [w1 oberr]=pwrspec2d(obs-interpn(x,y,truth,obs_x,obs_y));
  [w err1]=pwrspec2d(mean(prior(:,:,1:nens),3)-truth);
	[w sprd1]=sprdspec(prior(:,:,1:nens));

lc=[4:2:20 25:5:100];
for l=1:length(lc)

  psi1=enkf(psi,psi,dat,lc(l),1);

  post(:,:,:,k,l)=psi1;

	post_rmse(k,l)=sqrt(mean(mean((mean(post(:,:,1:nens,k,l),3)-truth).^2, 1),2));
	post_sprd(k,l)=sqrt(mean(mean(std(post(:,:,1:nens,k,l),[],3).^2, 1),2));

  [w err2(:,k,l)]=pwrspec2d(mean(post(:,:,1:nens,k,l),3)-truth);
	[w sprd2(:,k,l)]=sprdspec(post(:,:,1:nens,k,l));

  save sqg_localize_test
end
