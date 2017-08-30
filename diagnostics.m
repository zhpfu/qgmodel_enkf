%clear all
addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf/';
%expname='noda';
%nens=40;

getparams([workdir '/' expname '/truth']);
lv=1;

%for l=1:5
%casename=['sl' num2str(2^(l+loff))];

for n=1:nt-n1+1
n
  nid=sprintf('%5.5i',n+n1-1);
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut(:,:,n)=spec2grid(psi2u(psik(:,:,lv)));
  vt(:,:,n)=spec2grid(psi2v(psik(:,:,lv)));
  
  for m=1:nens
    psik1=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/f_' nid],nkx,nky,nz,1);
    psik2=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/' nid],nkx,nky,nz,1);
		u1(:,:,m,n)=spec2grid(psi2u(psik1(:,:,lv)));
		v1(:,:,m,n)=spec2grid(psi2v(psik1(:,:,lv)));
	  u2(:,:,m,n)=spec2grid(psi2u(psik2(:,:,lv)));
	  v2(:,:,m,n)=spec2grid(psi2v(psik2(:,:,lv)));
  end
end

	%out(:,:,1,:)=squeeze(mean(u1,3));
	%out(:,:,2,:)=squeeze(mean(u2,3));
	%out(:,:,3,:)=ut;
	%system(['mkdir -p ' workdir '/out/' expname]);
	%system(['rm -f ' workdir '/out/' expname '/' casename '.nc']);
	%nc_write([workdir '/out/' expname '/' casename '.nc'],'var',{'x','y','case','t'},out);

%error spectra
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
save([workdir '/errspec/' expname '/' casename],'w','err1','err2','sprd1','sprd2')

%end

