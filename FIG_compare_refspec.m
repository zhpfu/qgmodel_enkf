addpath util
workdir='/glade/scratch/mying/qgmodel_enkf'
close all
kmax=63; lv=1;
n=900;
for i=1:n
  psik(:,:,:,i)=read_field([workdir '/ctrl/truth/' sprintf('%5.5i',i)],2*kmax+1,kmax+1,lv,1);
end 
[w p0]=KEspec1(psik);
for i=1:n
  psik(:,:,:,i)=read_field([workdir '/scale1/truth/' sprintf('%5.5i',i)],2*kmax+1,kmax+1,lv,1);
end 
[w p1]=KEspec1(psik);
for i=1:n
  psik(:,:,:,i)=read_field([workdir '/scale2/truth/' sprintf('%5.5i',i)],2*kmax+1,kmax+1,lv,1);
end 
[w p2]=KEspec1(psik);
%[w p]=pwrspec2d(spec2grid(psi2u(psik)));

plotspec(w,squeeze(mean(p0(:,1,:),3)),1.03,'k','-',2); hold on  %top is 1
plotspec(w,squeeze(mean(p1(:,1,:),3)),1.03,'b','-',2); hold on  %top is 1
plotspec(w,squeeze(mean(p2(:,1,:),3)),1.03,'r','-',2); hold on  %top is 1

%w1=[1:100]; loglog(w1,(6e2)*w1.^(-3),'color',[.7 .7 .7],'linewidth',2); text(30,0.06,'-3','color',[.7 .7 .7],'fontsize',20);
legend('CNTL','Scale1','Scale2','location','southwest')

set(gca,'fontsize',18)
xlabel('wavenumber','fontsize',20)
ylabel('KE','fontsize',20)
axis([1 100 1e-4 1e1])
saveas(gca,'1','pdf')

system('scp 1.pdf yxy159@192.5.158.32:~/html/');
