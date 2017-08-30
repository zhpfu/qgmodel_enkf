addpath util
addpath ../graphics
workdir='/glade/scratch/mying/qgmodel_enkf/scale2'
close all
kmax=49; lv=2;
for i=1:n
  psik(:,:,:,i)=read_field([workdir '/truth/' sprintf('%5.5i',i)],2*kmax+1,kmax+1,lv,1);
end 
[w p]=KEspec1(psik);
%[w p]=pwrspec2d(spec2grid(psi2temp(psik)));

cmap=colormap(jet(n));
for i=1:1:n
	plotspec(w,squeeze(p(:,1,i)),1.03,cmap(i,:),'-',1); hold on  %top is 1
end
%plotspec(w,squeeze(mean(p(:,1,:),3)),1.03,'k','-',1); hold on  %top is 1

%loglog(w,(10^1)*w.^(-5/3),'color',[.5 .5 .5])
%loglog(w,(10^3)*w.^(-3),'color',[.5 .5 .5])

axis([0.8 120 1e-6 1e2])
saveas(gca,'1','pdf')

%system('rm -rf 1.nc');
%nc_write('1.nc','psi',{'x','y','z','t'},spec2grid(psik));
%nc_write('1.nc','zeta',{'x','y','z','t'},spec2grid(psi2zeta(psik)));

system('scp 1.pdf yxy159@192.5.158.32:~/html/');
