clear all
close all
addpath /glade/p/work/mying/qgmodel_enkf/util
workdir='/glade/scratch/mying/qgmodel_enkf';

k1=[1 6 22 1];
k2=[5 21 65 65];
ltext1={'CNTL @ L scale','CNTL @ M scale','CNTL @ S scale'};

varname='temp';
lv=1;
n1=50; nt=300;

expname={'TN64','scale1','scale2'};
ltext={'CNTL','M\_Scale','S\_Scale'};
color={[0 0 0],[0 0 1],[1 0 0]};

l=[8 12 16 20 24 32 40 48 64 256];

for k=1:length(k1)
for c=1:length(expname)
  for i=1:length(l)
    infile=[workdir '/errspec/' cell2mat(expname(c)) '/sl' num2str(l(i)) '_' varname '.mat'];
    if(exist(infile,'file')==2)
      load(infile);
      p=squeeze(mean(err2(:,lv,n1:nt),3));
      p=smooth_spec(w,p,1.03);
			err(k,c,i)=sqrt(sum(p(k1(k):k2(k))));
    else  
      err(k,c,i)=NaN;
    end
  end
end
end


subplot(2,2,1)
set(gca,'fontsize',12);
k=4;
for c=1:length(expname)
  plot(l,squeeze(err(k,c,:)),'o-','color',cell2mat(color(c)),'markersize',4,'markerfacecolor','w'); hold on
end
for c=1:length(expname)
  plot(l,squeeze(err(k,c,:)),'o','markersize',5,'markerfacecolor','w','markeredgecolor','w'); 
end
for c=1:length(expname)
	plot(l,squeeze(err(k,c,:)),'o','color',cell2mat(color(c)),'markersize',4);
  plot(l(err(k,c,:)==nanmin(err(k,c,:))),nanmin(err(k,c,:)),'o','color',cell2mat(color(c)),'markersize',4,'markerfacecolor',cell2mat(color(c)));
end
text(77,0.7,'\infty','color','k','fontsize',14);
axis([0 80 1 6])
set(gca,'XTick',[8 16 32 64]);
grid on
xlabel('ROI','fontsize',14);
h=legend(ltext,'location','northwest','fontsize',10);


subplot(2,2,2)
set(gca,'fontsize',12);
p=get(gca,'position'); p(1)=p(1)-0.05; set(gca,'position',p);
c=1;
for k=1:3
  plot(l,squeeze(err(k,c,:)),'o-','color',cell2mat(color(k)),'markersize',4,'markerfacecolor','w'); hold on
end
for k=1:3
  plot(l,squeeze(err(k,c,:)),'o','markersize',5,'markerfacecolor','w','markeredgecolor','w'); 
end
for k=1:3
	plot(l,squeeze(err(k,c,:)),'o','color',cell2mat(color(k)),'markersize',4);
  plot(l(err(k,c,:)==nanmin(err(k,c,:))),nanmin(err(k,c,:)),'o','color',cell2mat(color(k)),'markersize',4,'markerfacecolor',cell2mat(color(k)));
end
text(77,-0.18,'\infty','color','k','fontsize',14);
axis([0 80 0 3])
set(gca,'XTick',[8 16 32 64]);
grid on
xlabel('ROI','fontsize',14);
h=legend(ltext1,'location','northwest','fontsize',10);


saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')

close all
