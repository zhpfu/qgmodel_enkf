clear all
workdir='/glade/scratch/mying/qgmodel_enkf';
expname='ctrl';

load([workdir '/mcorr/' expname '/noda_upsi']);

nt=111;
cmap=colormap(jet(nt));
set(gca,'fontsize',18)

for n=1:10:nt
  plot(squeeze(mean(mcorr(n,:,1,:),2)),'color',cmap(n,:)*0.8); hold on 
end

set(gca,'XTick',1:10:65,'XTickLabel',0:10:64)
axis([1 60 0 0.5])
xlabel('distance','fontsize',22);
ylabel('mean abs correlation','fontsize',22);

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
