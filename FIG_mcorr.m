close all

set(gca,'fontsize',24)
%expname={'scale1','scale2','ctrl'}
%expname={'highres1','partial_domain','ctrl'};
%style={'r-','b-','k-'};
%expname={'N10','N20','ctrl','N80','N1000'};
expname={'ctrl'};

cmap=colormap(jet(5))*0.8;
cmap(6,:)=[0 0 0];

i=0;
for c=1:length(expname)
for l=[4 8 16 32 64 0]
i=i+1;
casename=['sl' num2str(l)];
%if (c==3); casename='sl16'; end
if (l==0); casename='noda'; end
x=0:50; 
%if (c==1); x=0:0.5:50; end 
%if (c==2); x=0:0.5:25; end 
load(['/glade/scratch/mying/qgmodel_enkf/mcorr1/' cell2mat(expname(c)) '/' casename])
mac=squeeze(mean(mean(mcorr(:,:,1,:),1),2)); 
macmin(c)=mean(mac(40:50));
plot(x,mac,'color',cmap(i,:),'linewidth',2); hold on
%plot(x,mac,cell2mat(style(c)),'linewidth',2); hold on
end
end
%for c=1:length(expname)
  %plot([0 50],[macmin(c) macmin(c)],'-','color',[.5 .5 .5]);
%end
axis([0 50 0 0.5])
xlabel('distance','fontsize',28)
%legend('LARGE\_SCALE','SMALL\_SCALE','CNTL')
%legend('HIGHRES','HIGHRES\_PART','CNTL')
%legend('ENS\_10','ENS\_20','ENS\_40','ENS\_80','ENS\_1000');
legend('ROI=4','ROI=8','ROI=16','ROI=32','ROI=64','No DA');

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
