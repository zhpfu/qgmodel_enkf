clear all
workdir='/glade/scratch/mying/qgmodel_enkf';
expname='uvN64';
casename='forecast';

load([workdir '/mcorr/' expname '/' casename]);

nt=30;
lv=1;
cmap=colormap(jet(nt));
set(gca,'fontsize',18)
p=get(gca,'position'); p(2)=p(2)+0.1; p(3)=p(3)-0.2; p(4)=p(4)-0.2; set(gca,'position',p);

for n=1:1:nt
  plot(squeeze(mean(mcorr(n,:,lv,:),2)),'color',cmap(n,:)*0.8); hold on 
end

set(gca,'XTick',1:10:65,'XTickLabel',0:10:64)
axis([1 60 0 0.4])
xlabel('distance','fontsize',22);
grid on

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
