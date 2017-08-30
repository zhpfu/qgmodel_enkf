%clear all
addpath /wall/s0/yxy159/qgmodel_enkf/util
addpath /wall/s0/yxy159/qgmodel_enkf/enkf
addpath /wall/s0/yxy159/graphics
workdir='/wall/s0/yxy159/qgmodel_enkf/sqg1';

%%%INITIALIZE
getparams([workdir '/truth']);

n=10;
nid=sprintf('%5.5i',n);
nens=20;

%read in prior ensemble 
for m=1:nens
  psik=read_field([workdir '/ensemble/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',n)],nkx,nky,nz,1);
  psi(:,:,:,m)=spec2grid(psik);
  temp(:,:,:,m)=spec2grid(psi2temp(psik));
end
psi(:,:,:,nens+1)=mean(psi(:,:,:,1:nens),4);
temp(:,:,:,nens+1)=mean(temp(:,:,:,1:nens),4);

prior=psi;

%observation
[x y]=ndgrid(1:nx,1:ny);
dat=textread([workdir '/obs_psi_randloc/' nid]);
%obs_x=reshape(dat(:,1),[nx ny];
%obs_y=reshape(dat(:,2),[nx ny]); 
%obs=reshape(dat(:,5),[nx ny]);

%truth
truth=spec2grid(squeeze(read_field([workdir '/truth/' nid],nkx,nky,nz,1)));

lc=[8 12 16 20 30 50 70 90 120];
for l=7:length(lc)

%%%EnKF TEST
obs_thin=1;
%define bands of scale
krange=1; %[3 8 20]
rho=lc(l) %[30 10 0]
post=enkf(prior,dat,rho,krange,obs_thin);
%post=enkf_allscale(prior,prior,dat,rho,obs_thin);

%%%DIAGNOSTICS
%domain averaged error/spread
prior_rmse=sqrt(mean(mean(mean((mean(prior(:,:,:,1:nens),4)-truth).^2, 1),2),3))
prior_sprd=sqrt(mean(mean(mean(std(prior(:,:,:,1:nens),[],4).^2, 1),2),3))
post_rmse=sqrt(mean(mean(mean((mean(post(:,:,:,1:nens),4)-truth).^2, 1),2),3))
post_sprd=sqrt(mean(mean(mean(std(post(:,:,:,1:nens),[],4).^2, 1),2),3))

%error spectra
[w ref]=pwrspec2d(truth);
%iind=1:obs_thin:nx; jind=1:obs_thin:ny;
%[w1 oberr]=pwrspec2d(obs(iind,jind)-interpn(x,y,truth,obs_x(iind,jind),obs_y(iind,jind)));
[w err1]=pwrspec2d(mean(prior(:,:,:,1:nens),4)-truth);
%[w sprd1]=sprdspec(prior(:,:,:,1:nens));
[w err2(:,l)]=pwrspec2d(mean(post(:,:,:,1:nens),4)-truth);
%[w sprd2]=sprdspec(post(:,:,:,1:nens));
%close all
%smth=1.01;
%set(gca,'fontsize',14)
%loglog(w,smooth_spec(w,ref,smth),'k','linewidth',2); hold on 
%loglog(w,smooth_spec(w,err1,smth),'b','linewidth',2);
%%loglog(w,smooth_spec(w,sprd1,smth),'g','linewidth',1);
%loglog(w,smooth_spec(w,err2,smth),'r','linewidth',2); 
%%loglog(w,smooth_spec(w,sprd2,smth),'b','linewidth',2); 
%loglog(w1,smooth_spec(w1,oberr,smth),'color',[.7 .7 .7],'linewidth',1);
%axis([1 128 1e-7 1])
%xlabel('wavenumber','fontsize',20);
%saveas(gca,'~/html/1','pdf')

save enkf_test_localize
end

%%output nc file
%out(:,:,:,1)=prior(:,:,:,nens+1);
%out(:,:,:,2)=post(:,:,:,nens+1);
%out(:,:,:,3)=truth;
%system('rm -f 1.nc');
%nc_write('1.nc','out',{'x','y','t','c'},out);
