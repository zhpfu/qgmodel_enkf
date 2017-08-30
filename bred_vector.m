
addpath /wall/s0/yxy159/qgmodel_enkf/util
addpath /wall/s0/yxy159/graphics
workdir='/wall/s0/yxy159/qgmodel_enkf/sqg';

close all

getparams([workdir '/truth']);

nens=15;
n=20;
nid=sprintf('%5.5i',n);

psik=read_field([workdir '/truth/' nid],nkx,nky,nz,1);
psi0=spec2grid(psik);
%[uk vk]=psi2uv(psik);
%u0=spec2grid(uk);
%v0=spec2grid(vk);

for m=1:nens
	psik=read_field([workdir '/bred_vector/' sprintf('%4.4i',m) '/f_' sprintf('%5.5i',n)],nkx,nky,nz,1);
  psi(:,:,m)=spec2grid(psik)-psi0;
	%[uk vk]=psi2uv(psik);
	%u(:,:,m)=spec2grid(uk);
	%v(:,:,m)=spec2grid(vk);
end
%nc_write('bred_vector.nc','psi',{'x','y','m'},psi);
%for m=1:nens
	%[w p(:,m,n)]=KEspec(u(:,:,m)-u0, v(:,:,m)-v0);
%end

%end

%save sqg_bredvector_spec.mat

%%%%spectra of BVs
%loglog(w,w.^(-5/3),'color',[.7 .7 .7],'linewidth',2); hold on
%for n=1:nt
  %loglog(w,smooth_spec(w,mean(p(:,:,n),2),1.01),'k-')
%end
%xlabel('wavenumber','fontsize',20)
%axis([1 100 1e-7 1])

%%%%separate BV into scales
%k1=[1  1  4 10];
%k2=[120 4 10 50];
%kstr={'all scales','k=1~4','k=4~10','k=10~50'};
%for m=1:nens;
%for k=1:4
	%subplot(2,2,k)
	%psiout=kfilter(psi(:,:,m),k1(k),k2(k));
	%contourf(psiout',[min(psiout(:)) -0.05:0.005:0.05 max(psiout(:))],'linestyle','none'); caxis([-0.05 0.05])
	%axis equal; axis([1 nx 1 ny])
  %title(cell2mat(kstr(k)),'fontsize',20)
	%set(gca,'XTickLabel',[],'YTickLabel',[])
%end
%saveas(gca,['~/html/qgmodel_enkf/sqg/bred_vector/' sprintf('%4.4i',m)],'pdf')
%end

%%%%plot the BVs
colormap(colormap_ncl('/wall/s0/yxy159/graphics/colormap/BlWhRe.rgb',21))
for m=1:nens
  subplot(4,4,m)
	p=get(gca,'pos'); p(3)=p(3)+0.03; p(4)=p(4)+0.03; set(gca,'pos',p);
  psiout=psi(:,:,m);
	contourf(psiout(100:150,150:200)',[min(psiout(:)) -0.1:0.01:0.1 max(psiout(:))],'linestyle','none'); caxis([-0.1 0.1])
	axis equal; axis([1 51 1 51])
	set(gca,'XTickLabel',[],'YTickLabel',[])
end

saveas(gca,'~/html/qgmodel_enkf/bredvectors','pdf')
