%clear all
addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf/';
%expname=
%nens=40;

%obs_thin=8; 
%if(run==1); obs_thin=4; end
%if(run==2); obs_thin=4; end
%if(run==3); obs_thin=1; end

getparams([workdir '/' expname '/truth']);

[x y]=ndgrid(1:nx,1:ny);
lv=1;
iind=1:obs_thin:nx; jind=1:obs_thin:ny;

%nt=21;
%n1=1; %nt-20;
for n=1:nt-n1+1
n
  nid=sprintf('%5.5i',n+n1-1);
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut(:,:,n)=spec2grid(psi2u(psik(:,:,lv)));
  vt(:,:,n)=spec2grid(psi2v(psik(:,:,lv)));
  
	for m=1:nens
		psik1=read_field([workdir '/' expname '/noda/' sprintf('%4.4i',m) '/f_' nid],nkx,nky,nz,1);
		psik2=read_field([workdir '/' expname '/noda/' sprintf('%4.4i',m) '/f_' nid],nkx,nky,nz,1);
		u1(:,:,m,n)=spec2grid(psi2u(psik1(:,:,lv)));
		v1(:,:,m,n)=spec2grid(psi2v(psik1(:,:,lv)));
		u2(:,:,m,n)=spec2grid(psi2u(psik2(:,:,lv)));
		v2(:,:,m,n)=spec2grid(psi2v(psik2(:,:,lv)));
	end
	a=textread([workdir '/' expname '/obs/' nid]);
	obs_x=reshape(a(:,1),[nx ny]);
	obs_y=reshape(a(:,2),[nx ny]); 
	obsu(:,:,n)=reshape(a(:,4),[nx ny]);
	obsv(:,:,n)=reshape(a(:,5),[nx ny]);
	obsuerr(:,:,n)=obsu(iind,jind,n)-interpn(x,y,ut(:,:,n),obs_x(iind,jind),obs_y(iind,jind));
	obsverr(:,:,n)=obsv(iind,jind,n)-interpn(x,y,vt(:,:,n),obs_x(iind,jind),obs_y(iind,jind));
end

	%out(:,:,1,:)=squeeze(mean(u1,3));
	%out(:,:,2,:)=obsu;
	%out(:,:,3,:)=ut;
	%system(['mkdir -p ' workdir '/' expname]);
	%system(['rm -f ' workdir '/' expname '/noda.nc']);
	%nc_write([workdir '/' expname '/noda.nc'],'var',{'x','y','z','case','t'},out);

%error spectra
[w ref]=KEspec(ut,vt);
[w1 oberr]=KEspec(obsuerr,obsverr);
u1mean=mean(u1,3);
v1mean=mean(v1,3);
u2mean=mean(u2,3);
v2mean=mean(v2,3);
for m=1:nens
	u1(:,:,m,:)=u1(:,:,m,:)-u1mean;
	v1(:,:,m,:)=v1(:,:,m,:)-v1mean;
	u2(:,:,m,:)=u2(:,:,m,:)-u2mean;
	v2(:,:,m,:)=v2(:,:,m,:)-v2mean;
end
[w err1]=KEspec(squeeze(u1mean)-ut,squeeze(v1mean)-vt);
[w err2]=KEspec(squeeze(u2mean)-ut,squeeze(v2mean)-vt);
[w p1]=KEspec(u1,v1);
[w p2]=KEspec(u2,v2);
sprd1=squeeze(sum(p1,2)./(nens-1));
sprd2=squeeze(sum(p2,2)./(nens-1));
system(['mkdir -p ' workdir '/errspec/' expname]);
save([workdir '/errspec/' expname '/noda'],'w','w1','ref','oberr','err1','err2','sprd1','sprd2')

