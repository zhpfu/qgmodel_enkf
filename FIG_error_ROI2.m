clear all
close all
addpath /glade/p/work/mying/qgmodel_enkf/util
workdir='/glade/scratch/mying/qgmodel_enkf';

k1=[1 6];
k2=[5 22];
ktitle={'(a) L scale                         ','(b) M scale                        '};

varname='temp';
lv=1;
n1=50; nt=300;

y1=[0.0 1.0];
y2=[1.5 2.0];
yloc=[-0.1 0.94];
expname={'TN64','lowres','lowres_model','lowres2','lowres2_model'};
ltext={'CNTL','LowRes','LowRes\_Model','LowRes2','LowRes2\_Model'};
color={[0 0 0],[1 0 0],[0 0 1],[.8 .4 .8],[.9 .5 0]};

l=[8 12 16 20 24 32 40 48 64 256];

for k=1:length(k1)
for c=1:length(expname)
  for i=1:length(l)
    infile=[workdir '/errspec/' cell2mat(expname(c)) '/sl' num2str(l(i)) '_' varname '.mat'];
    if(exist(infile,'file')==2)
      load(infile);
      p=squeeze(mean(err2(:,lv,n1:min(nt,end)),3));
      p=smooth_spec(w,p,1.03);
			err(k,c,i)=sqrt(sum(p(k1(k):k2(k))));
    else  
      err(k,c,i)=NaN;
    end
  end
end
end
for k=1:length(k1)
  subplot(2,1,k)
  set(gca,'fontsize',12);
  p=get(gca,'position'); p(3)=p(3)-0.4; p(4)=p(4); set(gca,'position',p);
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
  text(77,yloc(k),'\infty','color','k','fontsize',16);

	axis([0 80 y1(k) y2(k)])
  set(gca,'XTick',[8 16 32 64]);
  grid on
	if(k==2); xlabel('ROI','fontsize',16); end
	if(k==1); h=legend(ltext); set(h,'fontsize',12,'location','north'); end
  title(cell2mat(ktitle(k)),'fontsize',18)

end

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')

close all
