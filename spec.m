addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/lowres3';
close all
kmax=31; lv=1;
n=300;
figure
p=get(gca,'position'); p(2)=p(2)+0.1; p(3)=p(3)-0.2; p(4)=p(4)-0.2; set(gca,'position',p);
for i=1:n
  psik(:,:,:,i)=read_field([workdir '/truth/' sprintf('%5.5i',i)],2*kmax+1,kmax+1,lv,1);
end 
[w p]=KEspec1(psik);
%[w p]=pwrspec2d(spec2grid(psi2u(psik)));

cmap=colormap(jet(n));
%for i=1:1:n
	%plotspec(w,squeeze(p(:,1,i)),1.03,cmap(i,:),'-',1); hold on  %top is 1
%end
plotspec(w,squeeze(mean(p(:,1,:),3)),1.03,[.7 .7 .7],'-',2); hold on  %top is 1


kmax=63;
for i=1:n
	psik1(:,:,:,i)=read_field([workdir '/../TN1024/truth/' sprintf('%5.5i',i)],2*kmax+1,kmax+1,lv,1);
end 
[w1 p1]=KEspec1(psik1);
plotspec(w1,squeeze(mean(p1(:,1,:),3)),1.03,'k','-',2); hold on  %top is 1

%w1=[1:100]; loglog(w1,(6e2)*w1.^(-3),'color',[.7 .7 .7],'linewidth',2); text(30,0.06,'-3','color',[.7 .7 .7],'fontsize',20);

set(gca,'fontsize',18)
axis([1 100 1e-4 1e1])
xlabel('wavenumber','fontsize',20)
set(gca,'YTick',10.^[-10:10]);
grid on

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/');
close all
