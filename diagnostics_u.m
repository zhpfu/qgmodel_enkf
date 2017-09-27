%clear all
addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf/';
%expname='noda';
%casename=['sl' num2str(2^(l+loff))];
%nens=40;

getparams([workdir '/' expname '/truth']);

system(['mkdir -p ' workdir '/errspec/' expname]);
if(exist([workdir '/errspec/' expname '/' casename '_u'],'file')==2)
  load([workdir '/errspec/' expname '/' casename '_u'],'w','err1','err2') %,'sprd1','sprd2')
end
%for n=1:floor((nt-n1)/dt)+1
  %nid=sprintf('%5.5i',n1+(n-1)*dt)
for n=n1:nt
  nid=sprintf('%5.5i',n)
  psik=read_field([workdir '/' expname '/truth/' nid],nkx,nky,nz,1);
  ut=spec2grid(psi2u(psik));
  
  for m=1:nens
    psik1=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/f_' nid],nkx,nky,nz,1);
    psik2=read_field([workdir '/' expname '/' casename '/' sprintf('%4.4i',m) '/' nid],nkx,nky,nz,1);
		u1(:,:,:,m)=spec2grid(psi2u(psik1));
	  u2(:,:,:,m)=spec2grid(psi2u(psik2));
  end
  u1mean=mean(u1,4);
  u2mean=mean(u2,4);
  %for m=1:nens
    %u1(:,:,:,m)=u1(:,:,:,m)-u1mean;
    %u2(:,:,:,m)=u2(:,:,:,m)-u2mean;
  %end

  [w err1(:,:,n)]=pwrspec2d(u1mean-ut);
  [w err2(:,:,n)]=pwrspec2d(u2mean-ut);
  %[w p1(:,:,:,n)]=pwrspec2d(u1);
  %[w p2(:,:,:,n)]=pwrspec2d(u2);
  %sprd1=squeeze(sum(p1,3)./(nens-1));
  %sprd2=squeeze(sum(p2,3)./(nens-1));

	%out(:,:,:,1,n)=u1mean;
	%out(:,:,:,2,n)=u2mean-u1mean;
	%out(:,:,:,3,n)=ut;
save([workdir '/errspec/' expname '/' casename '_u'],'w','err1','err2') %,'sprd1','sprd2')
end


%system(['mkdir -p ' workdir '/out/' expname]);
%system(['rm -f ' workdir '/out/' expname '/' casename '.nc']);
%nc_write([workdir '/out/' expname '/' casename '.nc'],'var',{'x','y','case','t'},out);

