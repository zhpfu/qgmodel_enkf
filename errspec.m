addpath util
workdir='/glade/scratch/mying/qgmodel_enkf';
smth=1.03;

expname='TN64';
expname0='TN64';
varname='temp';

nl=[8 16 32 64];
cmap1=0.8*colormap(jet(5)); cmap1(3,:)=[];

factor=1;
lv=1;
n1=50; nt=300;

close all
	set(gca,'fontsize',20)
  p=get(gca,'position'); p(2)=p(2)+0.1; p(3)=p(3)-0.2; p(4)=p(4)-0.2; set(gca,'position',p);
	
	for l=length(nl):-1:1
		load([workdir '/errspec/' expname '/sl' num2str(nl(l)) '_' varname])
		plotspec(w*factor,mean(err2(:,lv,n1:nt)/factor,3),smth,cmap1(l,:),'-',2); hold on
		%plotspec(w*factor,mean(sprd1(:,lv,n1:nt)/factor,3),smth,cmap1(l,:),'.',2); hold on
	end

	%load([workdir '/errspec/' expname0 '/noda_' varname])
	%plotspec(w*factor,mean(err1(:,lv,n1:nt)/factor,3),smth,'k','-',2); hold on
	%load([workdir '/errspec/TN64/noda_' varname])
	%plotspec(w*factor,mean(err1(:,lv,n1:nt)/factor,3),smth,'k','.',2); hold on
	load([workdir '/errspec/' expname0 '/ref_' varname])
	plotspec(w*factor,mean(ref(:,lv,n1:nt)/factor,3),smth,'k','-',2); hold on
	load([workdir '/errspec/' expname '/oberr_' varname])
	plotspec(w1*factor,mean(oberr(:,n1:nt)/factor,2),smth,[.7 .7 .7],'-',2)

	axis([1 100 1e-4 1e1])
	xlabel('wavenumber','fontsize',22)
  set(gca,'YTick',10.^[-10:10]);
	grid on;
	%ylabel('KE','fontsize',22);
	%h=legend('ROI=64','ROI=32','ROI=16','ROI=8','NoDA','ObsError');
	%set(h,'location','south','fontsize',20,'position',[0.8 0.3 0.1 0.1])

saveas(gca,'1','pdf')
system('scp 1.pdf yxy159@192.5.158.32:~/html/.')
close all
