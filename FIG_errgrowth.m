addpath util
workdir='/glade/scratch/mying/qgmodel_enkf/';
cmap1=colormap(jet(30));
smth=1.03; factor=1; 

close all
set(gca,'fontsize',14)
load([workdir '/errspec/ctrl/forecast'])
for n=1:30
	plotspec(w*factor,mean(err1(:,n)/factor,2),smth,cmap1(n,:),'-',1); hold on
end

load([workdir '/errspec/ctrl/noda'])
n=200:230;
plotspec(w*factor,mean(ref(:,n)/factor,2),smth,[.7 .7 .7],'-',1); hold on
plotspec(w*factor,mean(err1(:,n)/factor,2),smth,'k','-',2); hold on

	axis([0.8 120 1e-5 1e1])
	xlabel('wavenumber','fontsize',18)
	%ylabel('EKE','fontsize',18);


saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
%system(['scp -r ' workdir '/errspec/' casename ' yxy159@192.5.158.32:~/html/qgmodel_enkf/errspec/'])
