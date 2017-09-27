addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf';
expname='TN64';

close all
colormap(colormap_ncl('color_BlWhRe_bright.rgb',24))

casename='truth';

getparams([workdir '/' expname '/' casename]);

n=20;
nid=sprintf('%5.5i',n);

psik=read_field([workdir '/' expname '/' casename '/' nid],nkx,nky,nz,1);
psi=spec2grid(psik);
temp=spec2grid(psi2temp(psik));
u=spec2grid(psi2u(psik));
[x,y]=ndgrid(1:nx,1:ny);

subplot(2,2,1)
p=get(gca,'pos'); p(1)=p(1)-0.02; p(2)=p(2)-0.04; p(3)=p(3)+0.05; p(4)=p(4)+0.05; set(gca,'pos',p);
contourf(x,y,temp(:,:,1),[min(temp(:)) -24:2:24 max(temp(:))],'linestyle','none'); caxis([-24 24]); hold on
contour(x,y,psi(:,:,1),[1:1:10],'k');
contour(x,y,psi(:,:,1),[-10:1:-1],'color','k','linestyle',':');
h=colorbar('location','southoutside'); set(h,'position',[0.16 0.485 0.28 0.02]);
axis equal; axis([1 nx 1 ny])
title('(a) \theta                     ','fontsize',20)

subplot(2,2,2)
p=get(gca,'pos'); p(1)=p(1)-0.1; p(2)=p(2)-0.04; p(3)=p(3)+0.05; p(4)=p(4)+0.05; set(gca,'pos',p);
contourf(x,y,u(:,:,1),[min(u(:)) -12:12 max(u(:))],'linestyle','none'); caxis([-12 12]); hold on
contour(x,y,psi(:,:,1),[1:1:10],'k');
contour(x,y,psi(:,:,1),[-10:1:-1],'color','k','linestyle',':');
h=colorbar('location','southoutside'); set(h,'position',[0.52 0.485 0.28 0.02]);
axis equal; axis([1 nx 1 ny])
title('(b) u                     ','fontsize',20)


saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/');
close all
