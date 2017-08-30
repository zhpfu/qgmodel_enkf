close all
addpath util
addpath ../graphics
workdir='/glade/scratch/mying/qgmodel_enkf/';
smth=1.03;

colormap(colormap_ncl('/glade/p/work/mying/graphics/colormap/BlWhRe.rgb',41))

subplot(1,3,1)
set(gca,'fontsize',10)
psik=read_field([workdir '/ctrl/truth/00100'],99,50,2,1);
var=spec2grid(psi2zeta(psik(:,:,1)));
%var=spec2grid((psik(:,:,1)));
%p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
contourf(var',[min(var(:)) -100:5:100 max(var(:))],'linestyle','none'); caxis([-100 100])
%contourf(var',[min(var(:)) -5:0.25:5 max(var(:))],'linestyle','none'); caxis([-5 5])
axis equal; axis([1 100 1 100])

subplot(1,3,2)
set(gca,'fontsize',10)
psik=read_field([workdir '/highres1/truth/00100'],199,100,2,1);
var=spec2grid(psi2zeta(psik(:,:,1)));
%var=spec2grid((psik(:,:,1)));
%p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
contourf(var',[min(var(:)) -100:5:100 max(var(:))],'linestyle','none'); caxis([-100 100])
%contourf(var',[min(var(:)) -5:0.25:5 max(var(:))],'linestyle','none'); caxis([-5 5])
axis equal; axis([1 200 1 200])

subplot(1,3,3)
set(gca,'fontsize',10)
psik=read_field([workdir '/partial_domain/truth/00100'],99,50,2,1);
var=spec2grid(psi2zeta(psik(:,:,1)));
%var=spec2grid((psik(:,:,1)));
%p=get(gca,'pos'); p(3)=p(3)+0.08; p(4)=p(4)+0.08; set(gca,'pos',p);
contourf(var',[min(var(:)) -100:5:100 max(var(:))],'linestyle','none'); caxis([-100 100])
%contourf(var',[min(var(:)) -5:0.25:5 max(var(:))],'linestyle','none'); caxis([-5 5])
axis equal; axis([1 100 1 100])

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
