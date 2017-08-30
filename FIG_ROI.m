clear all
addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/';
%cmap=0.8*colormap(jet(5));
%cmap(6,:)=[0 0 0];

smth=1.03;
loff=1; 

%expname={'N10','N20','N40','N80'};
%sty={'v-','o-','-','x-','s-'};
%col={[0 0 1],[0 .7 .7],'k',[.7 .7 .3],[1 0 0]};
%expname={'ctrl','obs_err1','thin1','thin4','short_interval','long_interval'};
%sty={'-','s-','x-','o-','x-','o-'};
%col={'k',[.3 .7 .3],[0 .7 .7],[.7 .7 .3],[0 0 1],[1 0 0]};
expname={'N10_thin1','N10','N10_thin4'};
%expname={'N10_thin4_se','N10_thin4','thin4'};
%expname={'highres1','ctrl','partial_domain'};
%expname={'N10_scale1','N10','N10_scale2'};
%expname={'scale1','ctrl','scale2'};
sty={'x-','-','o-'};
%col={'r','k','b'};
col={[0 .7 .7],'k',[.7 .7 .3]};

	%load([workdir '/errspec/ctrl/noda'])
	%err_noda=sum(mean(err1(:,n),2),1);
	%err_ref=sum(mean(ref(:,n),2),1);
	%err_obs=sum(mean(oberr(:,n),2),1);

for c=1:length(expname)
	%l=[1 2 2.585 3 3.585 4 5];
	l=1:5;
  loff=1; %if(c==1 || c==3); loff=2; end
	for i=1:length(l)
		if(i==1 && c==3)
			err(i,c)=NaN;
		else
  		load([workdir '/errspec/' cell2mat(expname(c)) '/sl' num2str(round(2^(l(i)+loff)))])
  		n=1:500; if(c==5); n=1:21; end
  		err(i,c)=sum(mean(err2(:,n),2),1);
		end
	end
end

close all
set(gca,'fontsize',20)
for c=1:length(expname)
  semilogy(l,err(:,c),cell2mat(sty(c)),'color',cell2mat(col(c)),'linewidth',2,'markersize',10); hold on
end
%legend('CNTL','OBS\_ERR\_HALF','OBS\_DENSE','OBS\_SPARSE','OBS\_FREQ','OBS\_RARE')
%legend('ENS\_10','ENS\_20','ENS\_40','ENS\_80','location','southwest')
legend('OBS\_DENSE','ENS\_10','OBS\_SPARSE','location','southwest')
%legend('OBS\_FREQ','CNTL','OBS\_RARE')
%legend('HIGHRES','CNTL','HIGHRES\_PART')
%legend('LARGE\_SCALE','ENS\_10','SMALL\_SCALE')
set(gca,'XTick',1:5,'XTickLabel',[4 8 16 32 64]);
axis([1 5 1e-1 1e1])
xlabel('ROI','fontsize',25)

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
