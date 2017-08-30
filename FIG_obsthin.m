addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/';
cmap1=colormap(jet(5));
smth=1.03;

expname='ctrl';
nl=1:5; factor=1; loff=1;
%if(run==1); nl=[1:5]; factor=1; loff=2; end
%if(run==2); nl=[1:5]; factor=2; loff=2; end
%if(run==3); nl=[1:5]; factor=1; loff=1; end
%if(run==4); nl=[1:5]; factor=1; loff=3; end

%for n=1:nt-n1+1
close all
n=n1:nt
	set(gca,'fontsize',14)

	load([workdir '/errspec/' expname '/noda'])
	plotspec(w*factor,mean(err1(:,n)/factor,2),smth,[.0 .0 .0],'-',1); hold on
	%plotspec(w*factor,mean(sprd1(:,n)/factor,2),smth,'k','.',1); hold on
	plotspec(w*factor,mean(ref(:,n)/factor,2),smth,[.7 .7 .7],'-',1); hold on
	plotspec(w1*factor,mean(oberr(:,n)/factor,2),smth,[.7 .7 .7],'-',2)

	for ll=nl
		load([workdir '/errspec/' expname '/sl' num2str(2^(ll+loff))])
		plotspec(w*factor,mean(err2(:,n)/factor,2),smth,0.8*cmap1(ll,:),'-',2); hold on
		%plotspec(w*factor,mean(sprd2(:,n)/factor,2),smth,0.8*cmap1(ll,:),'.',2); hold on
		%plotspec(w*factor,mean(err1(:,n)/factor,2),smth,0.8*cmap1(ll,:),'.',1); hold on
		%plotspec(w*factor,mean(sprd1(:,n)/factor,2),smth,0.8*cmap1(ll,:),'.',1); hold on
		%plotspec(w*factor,mean(max(0.,err1(:,n)-err2(:,n))/factor,2),smth,0.8*cmap1(ll,:),'-',3); 
	end

	%load([workdir '/errspec/ctrl/sl_adapt'])
	%plotspec(w,mean(err2(:,n),2),smth,'k','-',1); hold on

	%load([workdir '/errspec/ctrl/ml_adapt'])
	%plotspec(w,mean(err2(:,n),2),smth,'k','.',1); hold on

	%plotspec(w,2e0*w.^(1/3),1,'k','.',1);
	%plotspec(w,2e-2*w.^(3),1,'k','.',1);

	axis([0.8 100 1e-5 1e1])
  xlabel('wavenumber','fontsize',18)
  ylabel('error power','fontsize',18);

%saveas(gca,[workdir '/errspec/' casename '/' sprintf('%5.5i',n)],'pdf')
%end
%plotspec(w*factor,mean(ref(:,n)/factor,2),smth,[.7 .7 .7],'-',1); hold on

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
%system(['scp -r ' workdir '/errspec/' casename ' yxy159@192.5.158.32:~/html/qgmodel_enkf/errspec/'])
