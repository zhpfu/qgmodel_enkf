close all

set(gca,'fontsize',24)

expname='N64';
vartype='T';
ll=[8 16 24 32 64];

cmap=colormap(jet(5))*0.8;
cmap(3,:)=[0 0 0];

style={'o','-','-'};

for s=[3 1];
for c=1:length(ll)
l=ll(c);
casename=['sl' num2str(l)];
if (l==0); casename='noda'; end
x=0:64;
load(['/glade/scratch/mying/qgmodel_enkf/mcorr/' vartype expname '/' casename])
mac=squeeze(mean(mean(mcorr(:,:,s,:),1),2)); 
macmin(c)=mean(mac(50:64));
plot(x,mac,cell2mat(style(s)),'color',cmap(c,:),'markerfacecolor',cmap(c,:),'markersize',2,'linewidth',2); hold on
end
end
axis([0 64 0 0.4])
xlabel('distance','fontsize',28)
set(gca,'XTick',0:10:60)
legend('ROI=8','ROI=16','ROI=24','ROI=32','ROI=64');

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
close all
