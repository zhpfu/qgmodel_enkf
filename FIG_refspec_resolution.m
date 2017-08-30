close all
addpath util
workdir='/glade/scratch/mying/qgmodel_enkf';
smth=1.03;

figure
set(gca,'fontsize',20)
load([workdir '/errspec/ctrl/noda'])
factor=1;
plotspec(w*factor,mean(ref(:,1:20)/factor,2),smth,'k','-',2); hold on

%load([workdir '/errspec/highres1/noda'])
%factor=1;
%plotspec(w*factor,mean(ref(:,1:20)/factor,2),smth,'r','-',2); hold on

%load([workdir '/errspec/partial_domain/noda'])
%factor=2;
%plotspec(w*factor,mean(ref(:,1:20)/factor,2),smth,'b','-',2); hold on

load([workdir '/errspec/scale1/noda'])
factor=1;
plotspec(w*factor,mean(ref(:,1:20)/factor,2),smth,'r','-',2); hold on

load([workdir '/errspec/scale2/noda'])
factor=1;
plotspec(w*factor,mean(ref(:,1:20)/factor,2),smth,'b','-',2); hold on

xlabel('wavenumber','fontsize',24)
axis([0.8 120 1e-5 1e1])
legend('CNTL','LARGE\_SCALE','SMALL\_SCALE')

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
