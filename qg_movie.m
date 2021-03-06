addpath /glade/p/work/mying/qgmodel_enkf/util
addpath /glade/p/work/mying/graphics
workdir='/glade/scratch/mying/qgmodel_enkf';
expname='lowres_model';

close all
colormap(colormap_ncl('color_BlWhRe_bright.rgb',21))

casename='truth';

getparams([workdir '/' expname '/' casename]);

for n=1:30
disp(n)
nid=sprintf('%5.5i',n);

psik=read_field([workdir '/' expname '/' casename '/' nid],nkx,nky,nz,1);
psi=spec2grid(psik);
temp=spec2grid(psi2temp(psik));
[uk vk]=psi2uv(psik); u=spec2grid(uk); v=spec2grid(vk);
zeta=spec2grid(psi2zeta(psik));
[x,y]=ndgrid(1:nx,1:ny);

subplot(2,2,1)
p=get(gca,'pos'); p(1)=p(1)-0.02; p(2)=p(2)-0.04; p(3)=p(3)+0.05; p(4)=p(4)+0.05; set(gca,'pos',p);
contourf(x,y,psi(:,:,1),[min(psi(:)) -5:0.5:5 max(psi(:))],'linestyle','none'); caxis([-5 5])
axis equal; axis([1 nx 1 ny])
set(gca,'XTickLabel',[],'YTickLabel',[])
title(['\psi'],'fontsize',18)

subplot(2,2,2)
p=get(gca,'pos'); p(1)=p(1)-0.1; p(2)=p(2)-0.04; p(3)=p(3)+0.05; p(4)=p(4)+0.05; set(gca,'pos',p);
contourf(x,y,zeta(:,:,1),[min(zeta(:)) -200:20:200 max(zeta(:))],'linestyle','none'); caxis([-200 200])
axis equal; axis([1 nx 1 ny])
set(gca,'XTickLabel',[],'YTickLabel',[])
title('\zeta','fontsize',18)

subplot(2,2,3)
p=get(gca,'pos'); p(1)=p(1)-0.02; p(2)=p(2)-0.04; p(3)=p(3)+0.05; p(4)=p(4)+0.05; set(gca,'pos',p);
contourf(x,y,temp(:,:,1),[min(temp(:)) -20:2:20 max(temp(:))],'linestyle','none'); caxis([-20 20])
axis equal; axis([1 nx 1 ny])
set(gca,'XTickLabel',[],'YTickLabel',[])
title('\theta','fontsize',18)

subplot(2,2,4)
p=get(gca,'pos'); p(1)=p(1)-0.1; p(2)=p(2)-0.04; p(3)=p(3)+0.05; p(4)=p(4)+0.05; set(gca,'pos',p);
contourf(x,y,u(:,:,1),[min(u(:)) -15:1.5:15 max(u(:))],'linestyle','none'); caxis([-15 15])
axis equal; axis([1 nx 1 ny])
set(gca,'XTickLabel',[],'YTickLabel',[])
title('u','fontsize',18)

system(['mkdir -p ' workdir '/movie/' expname '/' casename]);
saveas(gca,[workdir '/movie/' expname '/' casename '/' nid],'pdf');
end

%saveas(gca,'1','pdf')
%system('scp 1.pdf yxy159@192.5.158.32:~/html/');
