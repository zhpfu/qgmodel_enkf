close all

set(gca,'fontsize',24)

%vartype='uv';
%ll=[24 24 28 32 48];
vartype='T';
ll=[16 20 24 32 48];
expname={'N16','N32','N64','N256','N1024'};
cmap=[1 0 0; 1 .5 0; 0 0 0; .3 .7 .3; 0 .5 .9];

%cmap=colormap(jet(5))*0.8;
%cmap(3,:)=[];
%cmap(6,:)=[0 0 0];

for c=1:length(expname)
l=ll(c);
casename=['sl' num2str(l)];
if (l==0); casename='noda'; end
x=0:64;
load(['/glade/scratch/mying/qgmodel_enkf/mcorr/' vartype cell2mat(expname(c)) '/' casename])
mac=squeeze(mean(mean(mcorr(:,:,1,:),1),2)); 
macmin(c)=mean(mac(50:64));
plot(x,mac,'color',cmap(c,:),'linewidth',2); hold on
%end
end
for c=1:length(expname)
	plot([0 64],[macmin(c) macmin(c)],'-','color',[.5 .5 .5]);
end
axis([0 64 0 0.4])
xlabel('distance','fontsize',28)
set(gca,'XTick',0:10:60)
legend('N=16','N=32','N=64','N=256','N=1024');

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
