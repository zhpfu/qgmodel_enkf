clear all
close all
addpath /glade/p/work/mying/qgmodel_enkf/util
workdir='/glade/scratch/mying/qgmodel_enkf';

k1=[1 6 21];
k2=[5 20 64];
y1=[0.0 0.5 0.8];
y2=[1.0 2.5 1.6];
yloc=[-0.08 0.35 0.75];
ytag={'L (k=1~5)','M (k=6~20)','S (k=21~64)'};

varname='temp';
lv=1;
n1=1; nt=100;

%expname={'N1000','N256','N128','ctrl','N32','N16'};
expname={'assimT_N1000','assimT_N256','assimT_N128','assimT','assimT_N32','assimT_N16'};
color={[0.9 .5 .9],[0 .5 .9],[.3 .7 .3],[0 0 0],[0.9 .5 0],[1 0 0]};

l=[8 12 16 24 32 48 64 256];

for k=1:length(k1)
  for c=2:length(expname)
    for i=1:length(l)
      load([workdir '/errspec/' cell2mat(expname(c)) '/sl' num2str(l(i)) '_' varname]);
      err(k,c,i)=sqrt(squeeze(sum(mean(err2(k1(k):k2(k),lv,n1:nt),3))));
    end
  end
end
for k=1:length(k1)
  subplot(3,1,k)
  set(gca,'fontsize',10);
  p=get(gca,'position'); p(3)=p(3)-0.5; p(4)=p(4)+0.02; set(gca,'position',p);
  for c=length(expname):-1:2
    plot(l,squeeze(err(k,c,:)),'o-','color',cell2mat(color(c)),'markersize',3,'markerfacecolor','w'); hold on
  end
  for c=2:length(expname)
    plot(l,squeeze(err(k,c,:)),'o','markersize',4,'markerfacecolor','w','markeredgecolor','w'); 
  end
  for c=2:length(expname)
    plot(l,squeeze(err(k,c,:)),'o','color',cell2mat(color(c)),'markersize',3);
    plot(l(err(k,c,:)==min(err(k,c,:))),min(err(k,c,:)),'o','color',cell2mat(color(c)),'markersize',3,'markerfacecolor',cell2mat(color(c)));
  end
  text(77,yloc(k),'\infty','color','k','fontsize',14);

  axis([0 80 y1(k) y2(k)])
  set(gca,'XTick',[8 16 32 64]);
  grid on
	if(k==1); h=legend('N=16','N=32','N=64','N=128','N=256'); set(h,'location','northwest','fontsize',9); end
	if(k==3); xlabel('ROI','fontsize',14); end
  ylabel(cell2mat(ytag(k)),'fontsize',14);
end

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')

close all
