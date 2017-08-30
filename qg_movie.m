addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf/ctrl';

close all
colormap(colormap_ncl('/glade/p/work/mying/graphics/colormap/BlWhRe.rgb',41))

casename='truth';

getparams([workdir '/' casename]);

for n=100:200
disp(n)
nid=sprintf('%5.5i',n);

psik=read_field([workdir '/' casename '/' nid],nkx,nky,nz,1);
psi=spec2grid(psik);
temp=spec2grid(psi2temp(psik));
[uk vk]=psi2uv(psik); u=spec2grid(uk); v=spec2grid(vk);
zeta=spec2grid(psi2zeta(psik));
[x,y]=ndgrid(1:nx,1:ny);

subplot(1,2,1)
p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
contourf(x,y,psi(:,:,1),[min(psi(:)) -5:0.25:5 max(psi(:))],'linestyle','none'); caxis([-5 5])
axis equal; axis([1 nx 1 ny])
set(gca,'XTickLabel',[],'YTickLabel',[])
title(['\psi_1'],'fontsize',20)

subplot(1,2,2)
p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
contourf(x,y,zeta(:,:,1),[min(zeta(:)) -100:5:100 max(zeta(:))],'linestyle','none'); caxis([-100 100])
axis equal; axis([1 nx 1 ny])
set(gca,'XTickLabel',[],'YTickLabel',[])
title('\zeta_1','fontsize',20)

%subplot(2,2,3)
%p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
%contourf(x,y,temp(:,:,1),[min(temp(:)) -20:20 max(temp(:))],'linestyle','none'); caxis([-20 20])
%axis equal; axis([1 nx 1 ny])
%set(gca,'XTickLabel',[],'YTickLabel',[])
%title(['\theta'],'fontsize',20)

%subplot(2,2,4)
%p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
%contourf(x,y,u(:,:,1),[min(u(:)) -20:20 max(u(:))],'linestyle','none'); caxis([-20 20])
%axis equal; axis([1 nx 1 ny])
%set(gca,'XTickLabel',[],'YTickLabel',[])
%title('u','fontsize',20)

saveas(gca,[nid],'pdf')

end

%saveas(gca,'1','pdf')
%system('scp 1.pdf yxy159@192.5.158.32:~/html/');
